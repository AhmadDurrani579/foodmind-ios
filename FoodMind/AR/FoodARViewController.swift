//
//  FoodARViewController.swift
//  FoodMind
//
//  AR/FoodARViewController.swift
//
//


import UIKit
import ARKit
import SceneKit

class FoodARViewController: UIViewController {

    // ── Data ──────────────────────────
    var backendResult:      BackendScanResult?
    var yoloBBox:           [Double] = []
    var foodImage:          UIImage?
    var modelURL:           String?
    var onPlaced:           (() -> Void)?
    var onStatusChange:     ((String) -> Void)?
    var onIngredientTapped: ((ScanIngredient) -> Void)?
    var onDishTapped:       (() -> Void)?

    // ── ARKit ─────────────────────────
    var sceneView:          ARSCNView!
    private var configuration: ARWorldTrackingConfiguration!

    // ── State ─────────────────────────
    private var isPlaced      = false
    private var planeDetected = false
    private var anchorNode:   SCNNode?
    private var labelNodes:   [SCNNode] = []
    private var planeNodes:   [ARAnchor: SCNNode] = [:]

    // ── Node name constants ───────────
    private let dishNodeName     = "dish_main"
    private let ingredientPrefix = "ingredient_"
    
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let lightHaptic  = UIImpactFeedbackGenerator(style: .light)

    // ── Label colours ─────────────────
    private let labelColors: [UIColor] = [
        UIColor(red: 0.55, green: 0.72, blue: 0.48, alpha: 1),
        UIColor(red: 0.95, green: 0.79, blue: 0.30, alpha: 1),
        UIColor(red: 0.91, green: 0.51, blue: 0.29, alpha: 1),
        UIColor(red: 0.48, green: 0.72, blue: 0.85, alpha: 1),
        UIColor(red: 0.85, green: 0.48, blue: 0.72, alpha: 1),
    ]

    // ─────────────────────────────────
    // MARK: — Lifecycle
    // ─────────────────────────────────
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // ─────────────────────────────────
    // MARK: — Setup
    // ─────────────────────────────────
    private func setupARView() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask             = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate                     = self
        sceneView.showsStatistics              = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.antialiasingMode             = .multisampling4X
        sceneView.rendersCameraGrain           = true
        sceneView.rendersMotionBlur            = true
        sceneView.allowsCameraControl          = false
        view.addSubview(sceneView)
    }

    private func startARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            onStatusChange?("ARKit not supported on this device"); return
        }
        configuration                      = ARWorldTrackingConfiguration()
        configuration.planeDetection       = []              // not needed for camera-fixed
        configuration.environmentTexturing = .automatic
        
        mediumHaptic.prepare()
        lightHaptic.prepare()

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics = .personSegmentationWithDepth
        } else if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
            configuration.frameSemantics = .personSegmentation
        }

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        onStatusChange?("Point camera and tap to place")
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        sceneView.addGestureRecognizer(pinch)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(pan)
        
        // Allow pinch and tap to work simultaneously
        tap.require(toFail: pan)
    }
    
    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {
        guard isPlaced, let anchor = anchorNode else { return }
        let newScale = Float(g.scale) * anchor.scale.x
        let clamped  = max(0.3, min(3.0, newScale))
        anchor.scale = SCNVector3(clamped, clamped, clamped)
        g.scale      = 1   // reset each frame so it's relative not absolute
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard isPlaced, let anchor = anchorNode else { return }
        let t          = g.translation(in: sceneView)
        let speed: Float = 0.0006
        anchor.position.x += Float(t.x) * speed
        anchor.position.y -= Float(t.y) * speed
        g.setTranslation(.zero, in: sceneView)
    }



    // ─────────────────────────────────
    // MARK: — Tap Gesture
    // ─────────────────────────────────
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        if !isPlaced {
            placeAtCentre()
            return
        }
        let hits = sceneView.hitTest(location, options: [
            SCNHitTestOption.searchMode:      SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.backFaceCulling: false,
            SCNHitTestOption.boundingBoxOnly: false
        ])
        for hit in hits {
            if let named = firstNamedAncestor(of: hit.node) {
                if named.name == dishNodeName {
                    handleDishTap(node: named); return
                } else if let name = named.name,
                          name.hasPrefix(ingredientPrefix),
                          let idx = Int(name.dropFirst(ingredientPrefix.count)) {
                    handleIngredientTap(index: idx, node: named); return
                }
            }
        }
    }

    private func firstNamedAncestor(of node: SCNNode) -> SCNNode? {
        var n: SCNNode? = node
        while let current = n {
            if let name = current.name,
               name == dishNodeName || name.hasPrefix(ingredientPrefix) { return current }
            n = current.parent
        }
        return nil
    }

    // ─────────────────────────────────
    // MARK: — Camera-Fixed Placement
    //
    // Places food 0.55m in front of the camera at screen centre.
    // No plane detection needed — works pointed at wall, air, table, anywhere.
    // ─────────────────────────────────
    private func placeAtCentre() {
        guard let camera = sceneView.pointOfView else { return }

        // Build a transform 0.55m directly in front of camera
        var t      = camera.simdWorldTransform
        // Camera looks along -Z in SceneKit world space
        // Move 0.55m forward (negative Z column)
        let dist: Float = 0.55
        t.columns.3.x  += -t.columns.2.x * dist
        t.columns.3.y  += -t.columns.2.y * dist
        t.columns.3.z  += -t.columns.2.z * dist

        // Reset rotation — keep only the translation so the
        // food sits upright regardless of camera tilt angle
        // (prevents burger appearing sideways when looking down)
        var uprightT        = simd_float4x4(1)   // identity
        uprightT.columns.3  = t.columns.3        // copy world position only

        placeFoodLabels(at: uprightT)
    }

    // ─────────────────────────────────
    // MARK: — Auto Place Using YOLO
    // ─────────────────────────────────
    func autoPlaceLabels() {
        guard !isPlaced else { return }
        placeAtCentre()
    }

    // ─────────────────────────────────
    // MARK: — Tap Handlers
    // ─────────────────────────────────
    private func handleIngredientTap(index: Int, node: SCNNode) {
        guard let result = backendResult, index < result.ingredients.count else { return }
        let ingredient = result.ingredients[index]

        // Run animation on main thread immediately — no dispatch needed
        node.runAction(SCNAction.sequence([
            SCNAction.scale(to: 1.20, duration: 0.09),
            SCNAction.scale(to: 0.93, duration: 0.07),
            SCNAction.scale(to: 1.00, duration: 0.09)
        ]))

        // Haptic fires instantly — generator already prepared
        mediumHaptic.impactOccurred()
        mediumHaptic.prepare()  // re-prepare for next tap

        // Callbacks are already on main thread from handleTap
        onIngredientTapped?(ingredient)
        onStatusChange?("\(ingredient.name) — \(ingredient.calories) kcal · \(ingredient.grams)g")
    }

    private func handleDishTap(node: SCNNode) {
        node.runAction(SCNAction.sequence([
            SCNAction.scale(to: 1.12, duration: 0.09),
            SCNAction.scale(to: 0.96, duration: 0.07),
            SCNAction.scale(to: 1.00, duration: 0.09)
        ]))
        lightHaptic.impactOccurred()
        lightHaptic.prepare()
        onDishTapped?()
    }

    // ─────────────────────────────────
    // MARK: — Place Food Labels
    // ─────────────────────────────────
    private func placeFoodLabels(at transform: simd_float4x4) {
        guard let result = backendResult else { return }

        isPlaced = true
        onPlaced?()
        configuration.planeDetection = []
        sceneView.session.run(configuration)
        for (_, n) in planeNodes { n.removeFromParentNode() }

        let rootNode       = SCNNode()
        rootNode.transform = SCNMatrix4(transform)
        sceneView.scene.rootNode.addChildNode(rootNode)
        anchorNode = rootNode

        // ── 1. Particle burst ──
        fireParticleBurst(on: rootNode)
        
        let score = computeHealthScore(result)
        makeScoreBadgeOnly(score: score, rootNode: rootNode)

        // ── 2. Food model ──
        if let url = modelURL, !url.isEmpty {
            load3DModel(url: url, rootNode: rootNode)
        } else {
            let model      = makeBuiltIn3DModel(for: result.dish_name)
            model.position = SCNVector3(0, 0, 0)
            model.opacity  = 0
            rootNode.addChildNode(model)
            model.runAction(SCNAction.sequence([
                SCNAction.wait(duration: 0.1),
                SCNAction.group([
                    SCNAction.fadeIn(duration: 0.7),
                    SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 0.7)
                ])
            ]))
            model.runAction(.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 18)))
            addFloat(to: model, amplitude: 0.004, period: 2.8)
        }

        // ── 3. Dish label — above burger ──
        let dishNode      = makeDishNode(result: result)
        dishNode.name     = dishNodeName
        dishNode.position = SCNVector3(0, 0.20, 0)
        dishNode.opacity  = 0
        rootNode.addChildNode(dishNode)
        dishNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 0.3),
            SCNAction.group([
                SCNAction.fadeIn(duration: 0.5),
                SCNAction.moveBy(x: 0, y: 0.015, z: 0, duration: 0.5)
            ])
        ]))

        // ── 4. Left/right menu labels ──
        placeMenuStyleLabels(result: result, rootNode: rootNode)

        onStatusChange?("Tap any label for details")
        print("✅ AR labels placed — camera-fixed, menu style")
    }

    // ─────────────────────────────────
    // MARK: — Menu Style Left/Right Labels
    //
    // Labels sit left and right of the burger in WORLD space.
    // Since the burger is upright and screen-centred, left/right
    // is simply positive/negative X in the root node's local space.
    // sideOffset is tuned so labels stay on screen at 0.55m distance.
    // ─────────────────────────────────
    private func placeMenuStyleLabels(result: BackendScanResult, rootNode: SCNNode) {
        let ingredients = Array(result.ingredients.prefix(6))
        guard !ingredients.isEmpty else { return }

        let sideOffset: Float = 0.11   // tighter — keeps right labels on screen

        // More spread — labels cover full burger height visibly
        let layerHeights: [Float] = [0.140, 0.105, 0.070, 0.040, 0.012, -0.020]

        for (index, ingredient) in ingredients.enumerated() {
            let isLeft   = (index % 2 == 0)
            let sideX: Float = isLeft ? -sideOffset : sideOffset

            let layerY: Float = index < layerHeights.count ? layerHeights[index] : 0.04
            let labelY: Float = layerY + 0.008

            let labelNode  = makeIngredientNode(ingredient: ingredient, index: index)
            labelNode.name = "\(ingredientPrefix)\(index)"

            let tintNode      = makeCalorieTintNode(for: ingredient)
            tintNode.position = SCNVector3(0, 0, -0.001)
            labelNode.addChildNode(tintNode)

            labelNode.position = SCNVector3(sideX, labelY, 0)
            labelNode.opacity  = 0
            rootNode.addChildNode(labelNode)
            labelNodes.append(labelNode)

            let delay = Double(index / 2) * 0.14 + 0.5
            labelNode.runAction(SCNAction.sequence([
                SCNAction.wait(duration: delay),
                SCNAction.group([
                    SCNAction.fadeIn(duration: 0.3),
                    SCNAction.moveBy(x: 0, y: 0.010, z: 0, duration: 0.3)
                ])
            ]))

            // Pointer dot on burger edge at layer height
            let tipX: Float = isLeft ? -0.072 : 0.072
            let tipY: Float = layerY
            let tipZ: Float = 0

            // Line from label to dot
            let ldx      = tipX - sideX
            let ldy      = tipY - labelY
            let lineDist = sqrt(ldx*ldx + ldy*ldy)
            guard lineDist > 0.005 else { continue }

            let midX = (sideX + tipX) / 2
            let midY = (labelY + tipY) / 2

            let lineMat              = SCNMaterial()
            lineMat.diffuse.contents = UIColor.white.withAlphaComponent(0.45)
            lineMat.lightingModel    = .constant
            let lineCyl              = SCNCylinder(radius: 0.0008, height: CGFloat(lineDist))
            lineCyl.materials        = [lineMat]
            let lineNode             = SCNNode(geometry: lineCyl)
            lineNode.position        = SCNVector3(midX, midY, 0)

            // ── Fixed rotation ──
            // SCNCylinder points along Y by default.
            // Rotate around Z axis to aim from label toward dot.
            let angle = atan2(ldx, ldy)
            lineNode.eulerAngles = SCNVector3(0, 0, -angle)

            lineNode.opacity = 0
            rootNode.addChildNode(lineNode)

            // Coloured dot at burger edge
            let dotMat              = SCNMaterial()
            dotMat.diffuse.contents = labelColors[index % labelColors.count]
            dotMat.lightingModel    = .constant
            let dotSphere           = SCNSphere(radius: 0.005)
            dotSphere.materials     = [dotMat]
            let dotNode             = SCNNode(geometry: dotSphere)
            dotNode.position        = SCNVector3(tipX, tipY, tipZ)
            dotNode.opacity         = 0
            rootNode.addChildNode(dotNode)

            let lineDelay = delay + 0.18
            lineNode.runAction(SCNAction.sequence([
                SCNAction.wait(duration: lineDelay),
                SCNAction.fadeIn(duration: 0.22)
            ]))
            dotNode.runAction(SCNAction.sequence([
                SCNAction.wait(duration: lineDelay),
                SCNAction.group([
                    SCNAction.fadeIn(duration: 0.22),
                    SCNAction.sequence([
                        SCNAction.scale(to: 1.8, duration: 0.12),
                        SCNAction.scale(to: 1.0, duration: 0.12)
                    ])
                ])
            ]))
        }
    }

    // ─────────────────────────────────
    // MARK: — Built-in 3D Model Builder
    // ─────────────────────────────────
    private func makeBuiltIn3DModel(for dishName: String) -> SCNNode {
        let n = dishName.lowercased()
        if n.contains("pizza")                             { return makePizza3D() }
        if n.contains("burger") || n.contains("sandwich") { return makeBurger3D() }
        if n.contains("salad")                             { return makeSalad3D() }
        if n.contains("pasta") || n.contains("spaghetti")
            || n.contains("noodle")                        { return makePasta3D() }
        return makeGenericFood3D()
    }
    
    private func computeHealthScore(_ result: BackendScanResult) -> Float {
        var score: Float = 100
        // Simple calorie-based score
        // 400 kcal or under = 100, 1200 kcal = 0
        let calScore = max(0, 100 - (Float(result.calories) - 400) / 8)
        score = calScore
        return max(0, min(100, score))
    }
    
    private func ringColor(for score: Float) -> UIColor {
        if score >= 80 {
            return UIColor(red: 0.11, green: 0.62, blue: 0.46, alpha: 1)  // green
        } else if score >= 45 {
            return UIColor(red: 0.94, green: 0.62, blue: 0.15, alpha: 1)  // amber
        } else {
            return UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1)  // red
        }
    }

    private func makeScoreBadgeOnly(score: Float, rootNode: SCNNode) {
        let color    = ringColor(for: score)
        let scoreInt = Int(score)
        let label    = scoreInt >= 80 ? "Healthy" : scoreInt >= 45 ? "Moderate" : "High cal"
        let image    = renderScoreLabel(score: scoreInt, label: label, color: color)

        let plane                             = SCNPlane(width: 0.10, height: 0.032)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel    = .constant
        plane.firstMaterial?.isDoubleSided    = true
        // ── Disable depth test so it never flickers behind other nodes ──
        plane.firstMaterial?.readsFromDepthBuffer  = false
        plane.firstMaterial?.writesToDepthBuffer   = false

        let node      = SCNNode(geometry: plane)
        node.position = SCNVector3(0, 0.26, 0)  // above dish label
        node.opacity  = 0
        // ── No float, no billboard constraint — just face camera via renderingOrder ──
        node.renderingOrder = 10               // always renders on top
        addBillboard(to: node)                 // keep billboard but NO addFloat call
        rootNode.addChildNode(node)

        // Simple fade in, no movement
        node.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 1.0),
            SCNAction.fadeIn(duration: 0.5)
        ]))
    }
    
    private func renderScoreLabel(score: Int, label: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 280, height: 90)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let rect = CGRect(origin: .zero, size: size)
            UIColor(white: 0.06, alpha: 0.92).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 18).fill()

            // Colour left bar
            color.setFill()
            UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 5, height: size.height),
                         cornerRadius: 2).fill()

            // Score number
            NSAttributedString(string: "\(score)", attributes: [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: color
            ]).draw(at: CGPoint(x: 20, y: 16))

            // Label text
            NSAttributedString(string: label, attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.white
            ]).draw(at: CGPoint(x: 72, y: 20))

            NSAttributedString(string: "health score", attributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.white.withAlphaComponent(0.45)
            ]).draw(at: CGPoint(x: 72, y: 42))
        }
    }

    private func makePizza3D() -> SCNNode {
        let root = SCNNode()
        addCyl(to: root, r: 0.115, h: 0.006, y: 0.003,
               c: UIColor(white: 0.88, alpha: 1), rg: 0.7)
        addCyl(to: root, r: 0.105, h: 0.014, y: 0.013,
               c: UIColor(red: 0.82, green: 0.58, blue: 0.28, alpha: 1), rg: 0.9)
        addCyl(to: root, r: 0.088, h: 0.005, y: 0.021,
               c: UIColor(red: 0.78, green: 0.18, blue: 0.10, alpha: 1), rg: 0.85)
        addCyl(to: root, r: 0.082, h: 0.004, y: 0.025,
               c: UIColor(red: 0.96, green: 0.82, blue: 0.30, alpha: 1), rg: 0.7)
        let tc = [UIColor(red: 0.18, green: 0.60, blue: 0.20, alpha: 1),
                  UIColor(red: 0.72, green: 0.10, blue: 0.10, alpha: 1),
                  UIColor(red: 0.85, green: 0.55, blue: 0.15, alpha: 1)]
        let tp: [(Float,Float)] = [
            (-0.04,0.04),(0.05,0.02),(-0.02,-0.05),(0.06,-0.04),
            (-0.06,-0.02),(0.03,0.06),(-0.05,0.05),(0.01,-0.07),
            (0.07,0.03),(-0.03,0.07),(0.04,-0.06),(-0.07,0.01)
        ]
        for (i,p) in tp.enumerated() {
            let s = SCNSphere(radius: 0.010)
            s.materials = [pbr(tc[i % tc.count], rg: 0.75)]
            let n = SCNNode(geometry: s)
            n.position = SCNVector3(p.0, 0.029, p.1)
            root.addChildNode(n)
        }
        return root
    }

    private func makeBurger3D() -> SCNNode {
        let root = SCNNode()
        var y: Float = 0
        // Layer order matches layerHeights[] in placeMenuStyleLabels
        let layers: [(UIColor, Float, Float)] = [
            (UIColor(red: 0.75, green: 0.45, blue: 0.18, alpha: 1), 0.068, 0.018), // bun bottom
            (UIColor(red: 0.35, green: 0.20, blue: 0.08, alpha: 1), 0.062, 0.016), // patty
            (UIColor(red: 0.92, green: 0.80, blue: 0.20, alpha: 1), 0.070, 0.005), // cheese
            (UIColor(red: 0.20, green: 0.60, blue: 0.15, alpha: 1), 0.066, 0.007), // lettuce
            (UIColor(red: 0.80, green: 0.15, blue: 0.10, alpha: 1), 0.064, 0.008), // tomato
            (UIColor(red: 0.80, green: 0.55, blue: 0.22, alpha: 1), 0.072, 0.032), // bun top
        ]
        for (c, r, h) in layers {
            addCyl(to: root, r: r, h: h, y: y + h/2, c: c, rg: 0.75)
            y += h + 0.001
        }
        [(-0.02,0.0),(0.02,0.01),(0.0,-0.03),(-0.03,0.02),(0.03,-0.01)].forEach { (sx,sz) in
            let s = SCNCapsule(capRadius: 0.004, height: 0.008)
            s.materials = [pbr(UIColor(red: 0.95, green: 0.88, blue: 0.55, alpha: 1), rg: 0.6)]
            let n = SCNNode(geometry: s)
            n.position    = SCNVector3(Float(sx), y - 0.005, Float(sz))
            n.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
            root.addChildNode(n)
        }
        return root
    }

    private func makeSalad3D() -> SCNNode {
        let root = SCNNode()
        let bowl = SCNSphere(radius: 0.08)
        bowl.materials = [pbr(UIColor(white: 0.90, alpha: 1), rg: 0.5)]
        let bn = SCNNode(geometry: bowl)
        bn.scale = SCNVector3(1, 0.55, 1); bn.position = SCNVector3(0, -0.02, 0)
        root.addChildNode(bn)
        let lc = [UIColor(red: 0.20, green: 0.65, blue: 0.25, alpha: 1),
                  UIColor(red: 0.35, green: 0.72, blue: 0.18, alpha: 1),
                  UIColor(red: 0.15, green: 0.55, blue: 0.20, alpha: 1)]
        let lp: [(Float,Float,Float)] = [
            (-0.03,0.04,0.02),(0.04,0.05,-0.02),(-0.02,0.06,-0.04),
            (0.05,0.04,0.03),(0.0,0.07,0.0),(-0.05,0.05,0.01),
            (0.03,0.06,0.04),(-0.04,0.04,-0.03)
        ]
        for (i,p) in lp.enumerated() {
            let l = SCNSphere(radius: 0.025)
            l.materials = [pbr(lc[i % lc.count], rg: 0.8)]
            let n = SCNNode(geometry: l)
            n.scale = SCNVector3(1.2, 0.4, 0.9); n.position = SCNVector3(p.0, p.1, p.2)
            root.addChildNode(n)
        }
        return root
    }

    private func makePasta3D() -> SCNNode {
        let root = SCNNode()
        addCyl(to: root, r: 0.10, h: 0.008, y: 0.004,
               c: UIColor(white: 0.92, alpha: 1), rg: 0.5)
        let m = SCNSphere(radius: 0.07)
        m.materials = [pbr(UIColor(red: 0.88, green: 0.72, blue: 0.38, alpha: 1), rg: 0.8)]
        let mn = SCNNode(geometry: m)
        mn.scale = SCNVector3(1, 0.45, 1); mn.position = SCNVector3(0, 0.022, 0)
        root.addChildNode(mn)
        [(0.0,0.0),(-0.03,0.03),(0.03,-0.02),(-0.02,-0.04),(0.04,0.02)].forEach { (sx,sz) in
            let s = SCNSphere(radius: 0.016)
            s.materials = [pbr(UIColor(red: 0.75, green: 0.15, blue: 0.10, alpha: 1), rg: 0.7)]
            let n = SCNNode(geometry: s)
            n.scale = SCNVector3(1, 0.5, 1); n.position = SCNVector3(Float(sx), 0.038, Float(sz))
            root.addChildNode(n)
        }
        return root
    }

    private func makeGenericFood3D() -> SCNNode {
        let root = SCNNode()
        addCyl(to: root, r: 0.10, h: 0.008, y: 0.004,
               c: UIColor(white: 0.92, alpha: 1), rg: 0.6)
        let m = SCNSphere(radius: 0.09)
        m.materials = [pbr(UIColor(red: 0.75, green: 0.55, blue: 0.28, alpha: 1), rg: 0.85)]
        let mn = SCNNode(geometry: m)
        mn.scale = SCNVector3(1, 0.55, 1); mn.position = SCNVector3(0, 0.045, 0)
        root.addChildNode(mn)
        return root
    }

    private func addCyl(to parent: SCNNode, r: Float, h: Float, y: Float,
                        c: UIColor, rg: Float) {
        let cyl = SCNCylinder(radius: CGFloat(r), height: CGFloat(h))
        cyl.materials = [pbr(c, rg: rg)]
        let n = SCNNode(geometry: cyl); n.position = SCNVector3(0, y, 0)
        parent.addChildNode(n)
    }

    private func pbr(_ color: UIColor, rg: Float) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents   = color
        m.lightingModel      = .physicallyBased
        m.roughness.contents = NSNumber(value: rg)
        m.metalness.contents = NSNumber(value: 0.0)
        return m
    }

    // ─────────────────────────────────
    // MARK: — Particle Burst
    // ─────────────────────────────────
    private func fireParticleBurst(on node: SCNNode) {
        let ps                       = SCNParticleSystem()
        ps.birthRate                 = 40
        ps.emissionDuration          = 0.3
        ps.particleLifeSpan          = 0.8
        ps.particleLifeSpanVariation = 0.2
        ps.particleVelocity          = 0.08
        ps.particleVelocityVariation = 0.04
        ps.spreadingAngle            = 60
        ps.particleSize              = 0.0008
        ps.particleSizeVariation     = 0.0004
        ps.particleColor             = UIColor(red: 0.55, green: 0.72, blue: 0.48, alpha: 0.9)
        ps.isAffectedByGravity       = false
        ps.acceleration              = SCNVector3(0, 0.04, 0)
        ps.blendMode                 = .additive
        let fadeAnim       = CAKeyframeAnimation()
        fadeAnim.values    = [0.0, 0.9, 0.0]
        fadeAnim.keyTimes  = [0, 0.3, 1.0]
        ps.propertyControllers = [
            SCNParticleSystem.ParticleProperty.opacity:
                SCNParticlePropertyController(animation: fadeAnim)
        ]
        let scaleAnim      = CAKeyframeAnimation()
        scaleAnim.values   = [1.0, 1.0, 0.0]
        scaleAnim.keyTimes = [0, 0.5, 1.0]
        ps.propertyControllers?[SCNParticleSystem.ParticleProperty.size] =
            SCNParticlePropertyController(animation: scaleAnim)
        node.addParticleSystem(ps)
    }

    // ─────────────────────────────────
    // MARK: — Node Builders
    // ─────────────────────────────────
    private func makeCalorieTintNode(for ingredient: ScanIngredient) -> SCNNode {
        let kcal: Float    = Float(ingredient.calories)
        let color: UIColor = kcal < 80
            ? UIColor(red: 0.20, green: 0.80, blue: 0.35, alpha: 0.28)
            : kcal < 200
                ? UIColor(red: 0.95, green: 0.72, blue: 0.10, alpha: 0.28)
                : UIColor(red: 0.90, green: 0.22, blue: 0.18, alpha: 0.28)
        let plane                             = SCNPlane(width: 0.108, height: 0.034)
        plane.firstMaterial?.diffuse.contents = color
        plane.firstMaterial?.lightingModel    = .constant
        plane.firstMaterial?.isDoubleSided    = true
        plane.firstMaterial?.blendMode        = .alpha
        return SCNNode(geometry: plane)
    }

    private func load3DModel(url: String, rootNode: SCNNode) {
        print("⬇️ Loading 3D model: \(url)")
        onStatusChange?("Loading 3D model...")
        guard let modelURL = URL(string: url) else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: modelURL)
                guard data.count > 4, data[0] == 0x50, data[1] == 0x4B else {
                    self.fallbackToBuiltIn(rootNode: rootNode); return
                }
                let tmp = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".usdz")
                try data.write(to: tmp)
                let scene     = try SCNScene(url: tmp, options: nil)
                let modelNode = SCNNode()
                scene.rootNode.childNodes.forEach { modelNode.addChildNode($0) }
                let (mn, mx) = modelNode.boundingBox
                let sz  = Swift.max(Swift.max(mx.x-mn.x, mx.y-mn.y), mx.z-mn.z)
                let sc  = Float(0.16) / Swift.max(sz, 0.001)
                modelNode.scale    = SCNVector3(sc, sc, sc)
                modelNode.position = SCNVector3(0, 0, 0)
                modelNode.opacity  = 0
                modelNode.enumerateChildNodes { c, _ in
                    c.geometry?.materials.forEach {
                        $0.lightingModel      = .physicallyBased
                        $0.roughness.contents = NSNumber(value: 0.55)
                        $0.metalness.contents = NSNumber(value: 0.0)
                    }
                }
                modelNode.runAction(.repeatForever(.rotateBy(x: 0, y: .pi*2, z: 0, duration: 10)))
                self.addFloat(to: modelNode, amplitude: 0.004, period: 2.5)
                DispatchQueue.main.async {
                    rootNode.addChildNode(modelNode)
                    modelNode.runAction(SCNAction.fadeIn(duration: 0.8))
                    self.onStatusChange?("Tap any label for details")
                }
                try? FileManager.default.removeItem(at: tmp)
            } catch { self.fallbackToBuiltIn(rootNode: rootNode) }
        }
    }

    private func fallbackToBuiltIn(rootNode: SCNNode) {
        guard let result = backendResult else { return }
        DispatchQueue.main.async {
            let m = self.makeBuiltIn3DModel(for: result.dish_name)
            m.position = SCNVector3(0, 0, 0); m.opacity = 0
            rootNode.addChildNode(m)
            m.runAction(SCNAction.sequence([
                SCNAction.fadeIn(duration: 0.6),
                SCNAction.repeatForever(.rotateBy(x: 0, y: .pi*2, z: 0, duration: 18))
            ]))
            self.addFloat(to: m, amplitude: 0.004, period: 2.8)
        }
    }

    private func makeDishNode(result: BackendScanResult) -> SCNNode {
        let image = renderLabel(
            emoji: "🍽️", title: result.dish_name,
            subtitle: "\(result.calories) kcal · \(result.confidence)% confident",
            color: UIColor(red: 0.55, green: 0.72, blue: 0.48, alpha: 1),
            size: CGSize(width: 480, height: 110), isMain: true)
        let plane                             = SCNPlane(width: 0.18, height: 0.042)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided    = true
        plane.firstMaterial?.lightingModel    = .constant
        plane.cornerRadius                    = 0.008
        let node = SCNNode(geometry: plane)
        addBillboard(to: node)
        addFloat(to: node, amplitude: 0.005, period: 2.0)
        return node
    }

    private func makeIngredientNode(ingredient: ScanIngredient, index: Int) -> SCNNode {
        let image = renderLabel(
            emoji: ingredient.emoji ?? "🍽️",
            title: ingredient.name,
            subtitle: "\(ingredient.calories) kcal · \(ingredient.grams)g",
            color: labelColors[index % labelColors.count],
            size: CGSize(width: 340, height: 90), isMain: false)
        let plane                             = SCNPlane(width: 0.10, height: 0.028)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided    = true
        plane.firstMaterial?.lightingModel    = .constant
        plane.cornerRadius                    = 0.005
        let node = SCNNode(geometry: plane)
        addBillboard(to: node)
        addFloat(to: node, amplitude: 0.002 + Float(index) * 0.0005,
                 period: 2.2 + Double(index) * 0.2)
        return node
    }

    private func makeRing(radius: Float) -> SCNGeometry {
        let t                             = SCNTorus(ringRadius: CGFloat(radius), pipeRadius: 0.0008)
        t.firstMaterial?.diffuse.contents = UIColor(red: 0.55, green: 0.72, blue: 0.48, alpha: 0.25)
        t.firstMaterial?.lightingModel    = .constant
        return t
    }

    private func renderLabel(emoji: String, title: String, subtitle: String,
                             color: UIColor, size: CGSize, isMain: Bool) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            let rect   = CGRect(origin: .zero, size: size)
            let radius = CGFloat(isMain ? 22 : 16)
            UIColor(white: 0.06, alpha: 0.92).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: radius).fill()
            color.setFill()
            UIBezierPath(roundedRect: CGRect(x: 0, y: 0,
                                             width: isMain ? 5 : 4, height: size.height),
                         cornerRadius: 2).fill()
            UIColor.white.withAlphaComponent(0.06).setStroke()
            let border = UIBezierPath(roundedRect: rect.insetBy(dx: 0.75, dy: 0.75),
                                      cornerRadius: radius)
            border.lineWidth = 1.5; border.stroke()
            NSAttributedString(string: emoji, attributes: [
                .font: UIFont.systemFont(ofSize: isMain ? 28 : 20)
            ]).draw(at: CGPoint(x: isMain ? 14 : 12, y: isMain ? 16 : 12))
            let tx: CGFloat = isMain ? 54 : 44
            NSAttributedString(string: title, attributes: [
                .font: UIFont.systemFont(ofSize: isMain ? 17 : 13, weight: .semibold),
                .foregroundColor: UIColor.white
            ]).draw(at: CGPoint(x: tx, y: isMain ? 16 : 11))
            NSAttributedString(string: subtitle, attributes: [
                .font: UIFont.systemFont(ofSize: isMain ? 13 : 11, weight: .regular),
                .foregroundColor: color.withAlphaComponent(0.85)
            ]).draw(at: CGPoint(x: tx, y: isMain ? 40 : 32))
            if isMain {
                let kt  = subtitle.components(separatedBy: " · ").first ?? ""
                let ks  = NSAttributedString(string: kt, attributes: [
                    .font: UIFont.systemFont(ofSize: 11, weight: .bold),
                    .foregroundColor: UIColor(white: 0.06, alpha: 1)
                ])
                let ksz = ks.size(); let kp: CGFloat = 10
                let kr  = CGRect(x: size.width - ksz.width - kp*2 - 12,
                                 y: (size.height - ksz.height - 10) / 2,
                                 width: ksz.width + kp*2, height: ksz.height + 10)
                color.setFill()
                UIBezierPath(roundedRect: kr, cornerRadius: kr.height/2).fill()
                ks.draw(at: CGPoint(x: kr.minX + kp, y: kr.minY + 5))
            }
            color.setFill()
            UIBezierPath(ovalIn: CGRect(x: size.width - (isMain ? 16 : 12),
                                        y: isMain ? 8 : 6,
                                        width: isMain ? 7 : 6,
                                        height: isMain ? 7 : 6)).fill()
        }
    }

    // ─────────────────────────────────
    // MARK: — Helpers
    // ─────────────────────────────────
    private func addBillboard(to node: SCNNode) {
        let b = SCNBillboardConstraint()
        b.freeAxes = .Y
        node.constraints = [b]
    }

    private func addFloat(to node: SCNNode, amplitude: Float, period: Double) {
        let up   = SCNAction.moveBy(x: 0, y: CGFloat(amplitude),  z: 0, duration: period)
        let down = SCNAction.moveBy(x: 0, y: CGFloat(-amplitude), z: 0, duration: period)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        node.runAction(.repeatForever(.sequence([up, down])))
    }

    func resetAR() {
        anchorNode?.removeFromParentNode()
        anchorNode    = nil
        labelNodes    = []
        isPlaced      = false
        planeDetected = false
        planeNodes.removeAll()
        startARSession()
    }
}

// ─────────────────────────────────────
// MARK: — ARSCNViewDelegate
// ─────────────────────────────────────
extension FoodARViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let pa = anchor as? ARPlaneAnchor else { return }
        let plane = SCNPlane(width:  CGFloat(pa.planeExtent.width),
                             height: CGFloat(pa.planeExtent.height))
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        plane.firstMaterial?.lightingModel    = .constant
        let pn = SCNNode(geometry: plane)
        pn.eulerAngles.x = -.pi / 2
        node.addChildNode(pn)
        planeNodes[anchor] = pn
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let pa = anchor as? ARPlaneAnchor,
              let pn = planeNodes[anchor],
              let pl = pn.geometry as? SCNPlane else { return }
        pl.width  = CGFloat(pa.planeExtent.width)
        pl.height = CGFloat(pa.planeExtent.height)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async { self.onStatusChange?("AR Error — try restarting") }
    }
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async { self.onStatusChange?("AR interrupted") }
    }
    func sessionInterruptionEnded(_ session: ARSession) { resetAR() }
}

// ─────────────────────────────────────
// MARK: — SCNMatrix4 Init
// ─────────────────────────────────────
extension SCNMatrix4 {
    init(_ m: simd_float4x4) {
        self.init(
            m11: m.columns.0.x, m12: m.columns.0.y, m13: m.columns.0.z, m14: m.columns.0.w,
            m21: m.columns.1.x, m22: m.columns.1.y, m23: m.columns.1.z, m24: m.columns.1.w,
            m31: m.columns.2.x, m32: m.columns.2.y, m33: m.columns.2.z, m34: m.columns.2.w,
            m41: m.columns.3.x, m42: m.columns.3.y, m43: m.columns.3.z, m44: m.columns.3.w
        )
    }
}
