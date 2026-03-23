//
//  WebSocketManager.swift
//  FoodMind
//

import Foundation
import UIKit
import Combine

// ─────────────────────────────────────
// MARK: — Scan Result Models
// ─────────────────────────────────────
struct ScanIngredient: Codable, Identifiable, Equatable {
    var id:       String { name }
    let name:     String
    let calories: Int
    let grams:    Int
    let emoji:    String?
    let position: String?
}

struct RecipeStep: Codable, Identifiable, Equatable {
    let step:          Int
    let title:         String
    let description:   String
    let duration_mins: Int
    var id:            Int { step }
}

struct BackendScanResult: Codable, Equatable {
    let dish_name:    String
    let cuisine:      String
    let image_url:    String?
    let calories:     Int
    let protein_g:    Double
    let carbs_g:      Double
    let fat_g:        Double
    let fiber_g:      Double
    let confidence:   Int
    let health_score: Int
    let portion_size: String
    let ingredients:  [ScanIngredient]
    let recipe_steps: [RecipeStep]
    let cooking_tip:  String
    let tags:         [String]
    let allergens:    [String]
}

struct ValidationResult: Codable, Equatable {
    let validation_level:  String
    let dishes_agree:      Bool
    let calorie_diff_pct:  Double
    let final_confidence:  Int
    let validated_by:      [String]
    let mobilenet_dish:    String
    let gemini_dish:       String
}

// ─────────────────────────────────────
// MARK: — WebSocket Message Types
// ─────────────────────────────────────
enum WSMessageType: String {
    case connected   = "connected"
    case ping        = "ping"
    case pong        = "pong"
    case scan        = "scan"
    case scanStarted = "scan_started"
    case scanResult  = "scan_result"
    case scanError   = "scan_error"
    case error       = "error"
}

struct Model3DInfo: Codable {
    let url:     String
    let format:  String
    let name:    String
    let author:  String
    let license: String
}


// ─────────────────────────────────────
// MARK: — WebSocket State
// ─────────────────────────────────────
enum WSConnectionState {
    case disconnected
    case connecting
    case connected
    case error(String)
}



class WebSocketManager: NSObject, ObservableObject {

    // ── Published State ───────────────
    @Published var connectionState: WSConnectionState = .disconnected
    @Published var scanResult:      BackendScanResult? = nil
    @Published var validation:      ValidationResult?  = nil
    @Published var isScanning:      Bool               = false
    @Published var error:           String?            = nil
    @Published var imageURL:        String             = ""  // ← top level image URL
    @Published var yoloBBox: [Double] = []
    @Published var model3D: Model3DInfo?

    // ── Private ───────────────────────
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession:    URLSession?
    private var pingTimer:     Timer?
    @Published var segments: [[String: Any]] = []
    
    private let baseURL = "wss://ahmaddurrani-food-mind.hf.space/ws/scan"

    // ─────────────────────────────────
    // MARK: — Connect
    // ─────────────────────────────────
    func connect(token: String) {
        guard let url = URL(string: "\(baseURL)?token=\(token)") else {
            DispatchQueue.main.async { self.error = "Invalid URL" }
            return
        }

        DispatchQueue.main.async { self.connectionState = .connecting }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity       = true

        urlSession    = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()

        startListening()
        startPingTimer()

        print("🔌 Connecting to FoodMind backend...")
    }

    // ─────────────────────────────────
    // MARK: — Disconnect
    // ─────────────────────────────────
    func disconnect() {
        stopPingTimer()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        DispatchQueue.main.async { self.connectionState = .disconnected }
        print("📴 Disconnected from backend")
    }

    // ─────────────────────────────────
    // MARK: — Send Scan
    // ─────────────────────────────────
    func sendScan(image: UIImage, mobileNetResult: FoodClassificationResult) {
        guard case .connected = connectionState else {
            DispatchQueue.main.async { self.error = "Not connected to backend" }
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            DispatchQueue.main.async { self.error = "Could not process image" }
            return
        }

        let base64 = imageData.base64EncodedString()

        let payload: [String: Any] = [
            "type":  "scan",
            "image": base64,
            "mobilenet": [
                "dish":         mobileNetResult.dishName,
                "confidence":   mobileNetResult.confidence,
                "alternatives": mobileNetResult.allResults.map {
                    ["label": $0.label, "confidence": $0.confidence]
                }
            ]
        ]

        sendJSON(payload)

        DispatchQueue.main.async {
            self.isScanning = true
            self.error      = nil
            self.scanResult = nil
            self.imageURL   = ""  // ← reset
        }

        print("📤 Scan sent — dish: \(mobileNetResult.dishName) (\(mobileNetResult.confidencePercent)%)")
    }

    // ─────────────────────────────────
    // MARK: — Listen For Messages
    // ─────────────────────────────────
    private func startListening() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.startListening()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.connectionState = .error(error.localizedDescription)
                    self.isScanning      = false
                }
                print("❌ Receive error: \(error)")
            }
        }
    }

    // ─────────────────────────────────
    // MARK: — Handle Incoming Message
    // ─────────────────────────────────
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        var jsonString: String?

        switch message {
        case .string(let text):   jsonString = text
        case .data(let data):     jsonString = String(data: data, encoding: .utf8)
        @unknown default:         break
        }

        guard let jsonString = jsonString,
              let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String
        else { return }

        let msgType = WSMessageType(rawValue: type)

        switch msgType {

        case .connected:
            DispatchQueue.main.async { self.connectionState = .connected }
            print("✅ WebSocket connected to FoodMind backend")

        case .pong:
            print("🏓 Pong received")

        case .scanStarted:
            print("🔍 Backend started analysing...")

        case .scanResult:
            handleScanResult(json)

        case .scanError:
            let msg = json["message"] as? String ?? "Unknown error"
            DispatchQueue.main.async {
                self.isScanning = false
                self.error      = msg
            }
            print("❌ Scan error: \(msg)")

        case .error:
            let msg = json["message"] as? String ?? "Unknown error"
            DispatchQueue.main.async { self.error = msg }

        default:
            print("Unknown message type: \(type)")
        }
    }

    // ─────────────────────────────────
    // MARK: — Handle Scan Result
    // ─────────────────────────────────
    private func handleScanResult(_ json: [String: Any]) {
        guard let resultDict = json["result"] else {
            DispatchQueue.main.async {
                self.isScanning = false
                self.error = "Invalid result format"
            }
            return
        }

        // ── Get image_url from top level ──
        // Backend returns image_url at root level
        // not inside result dict
        let topLevelImageURL = json["image_url"] as? String ?? ""

        do {
            // ── Inject image_url into result dict ──
            var mutableResult = resultDict as! [String: Any]
            if mutableResult["image_url"] == nil || (mutableResult["image_url"] as? String ?? "").isEmpty {
                mutableResult["image_url"] = topLevelImageURL
            }

            let resultData = try JSONSerialization.data(withJSONObject: mutableResult)
            let result = try JSONDecoder().decode(BackendScanResult.self, from: resultData)

            // ── Decode validation ──────────────
            var validationResult: ValidationResult? = nil
            if let validationDict = json["validation"] {
                let validationData = try JSONSerialization.data(withJSONObject: validationDict)
                validationResult = try JSONDecoder().decode(ValidationResult.self, from: validationData)
            }
            
            if let yolo = json["yolo"] as? [String: Any],
               let bbox = yolo["bbox_norm"] as? [Double] {
                self.yoloBBox = bbox
            }
            DispatchQueue.main.async {
                self.scanResult = result
                self.validation = validationResult
                self.imageURL   = topLevelImageURL  // ← store for share
                self.segments   = json["segments"] as? [[String: Any]] ?? []
                self.isScanning = false
                if let modelData = json["model_3d"] as? [String: Any],
                   let url    = modelData["url"]    as? String,
                   let format = modelData["format"] as? String {
                    self.model3D = Model3DInfo(
                        url:     url,
                        format:  format,
                        name:    modelData["name"]    as? String ?? "",
                        author:  modelData["author"]  as? String ?? "",
                        license: modelData["license"] as? String ?? ""
                    )
                    print("🎯 3D model received: \(url)")
                }
            }

            print("✅ Result: \(result.dish_name) (\(result.calories) kcal, \(result.confidence)%)")
            print("🖼️ Image URL: \(topLevelImageURL.isEmpty ? "none" : topLevelImageURL)")

        } catch {
            DispatchQueue.main.async {
                self.isScanning = false
                self.error = "Could not parse result: \(error.localizedDescription)"
            }
            print("❌ Parse error: \(error)")
        }
    }

    // ─────────────────────────────────
    // MARK: — Send JSON
    // ─────────────────────────────────
    private func sendJSON(_ payload: [String: Any]) {
        guard let data   = try? JSONSerialization.data(withJSONObject: payload),
              let string = String(data: data, encoding: .utf8)
        else { return }

        webSocketTask?.send(.string(string)) { error in
            if let error = error { print("❌ Send error: \(error)") }
        }
    }

    // ─────────────────────────────────
    // MARK: — Ping Timer
    // ─────────────────────────────────
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendJSON(["type": "ping"])
        }
    }

    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    // ─────────────────────────────────
    // MARK: — Reset
    // ─────────────────────────────────
    func reset() {
        DispatchQueue.main.async {
            self.scanResult = nil
            self.validation = nil
            self.isScanning = false
            self.error      = nil
            self.imageURL   = ""
        }
    }
}

// ─────────────────────────────────────
// MARK: — URLSessionWebSocketDelegate
// ─────────────────────────────────────
extension WebSocketManager: URLSessionWebSocketDelegate {

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        print("✅ URLSession WebSocket opened")
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        DispatchQueue.main.async {
            self.connectionState = .disconnected
            self.isScanning      = false
        }
        stopPingTimer()
        print("📴 WebSocket closed: \(closeCode)")
    }
}
