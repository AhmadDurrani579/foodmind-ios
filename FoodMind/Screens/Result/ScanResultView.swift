//
//  ScanResultView.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI
 
struct ScanResultView: View {
 
    @Environment(\.dismiss) var dismiss
 
    let result:        FoodClassificationResult
    let backendResult: BackendScanResult
    var validation:    ValidationResult? = nil
    let image:         UIImage
    var imageURL: String = ""
    var onDismiss:     () -> Void = {}
    
    @State private var showRecipe     = false
    @State private var showShareSheet = false
    @State private var isSharing      = false
    @State private var shareSuccess   = false
    @State private var showAR = false
    @EnvironmentObject var wsManager: WebSocketManager

    
    @StateObject private var viewModel = FeedViewModel()
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
 
                    // Handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(FMColors.cream.opacity(0.2))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
 
                    ZStack(alignment: .bottomLeading) {

                        Image(uiImage: image.normalizedImage())
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipped()

                        LinearGradient(
                            colors: [FMColors.background, .clear],
                            startPoint: .bottom,
                            endPoint:   .center
                        )
                        .frame(height: 260)

                        // ── Scan Line Ingredient Overlay ──
                        ScanLineIngredientOverlay(
                            ingredients: backendResult.ingredients
                        )
                        .frame(height: 260)

                        // ── Dish name bottom left ─────────
                        VStack(alignment: .leading, spacing: 4) {
                            Text(backendResult.dish_name)
                                .font(.system(
                                    size: 24,
                                    weight: .semibold,
                                    design: .serif
                                ))
                                .italic()
                                .foregroundColor(FMColors.cream)

                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(validationColor)
                                Text("\(backendResult.confidence)% confident · \(backendResult.cuisine)")
                                    .font(.system(size: 11))
                                    .foregroundColor(FMColors.cream.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)
                    
                    VStack(spacing: 12) {
 
                        NutritionGrid(result: backendResult)
 
                        if let validation = validation {
                            ValidationCard(validation: validation)
                        }
 
                        if !backendResult.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(backendResult.tags, id: \.self) { tag in
                                        FeedTag(label: tag)
                                    }
                                }
                            }
                        }
 
                        IngredientsCard(ingredients: backendResult.ingredients)
 
                        if !backendResult.cooking_tip.isEmpty {
                            CookingTipCard(tip: backendResult.cooking_tip)
                        }
 
                        if !backendResult.allergens.isEmpty {
                            AllergensCard(allergens: backendResult.allergens)
                        }
 
                        // ── Success Banner ───────────
                        if shareSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(FMColors.green)
                                Text("Shared to Feed!")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(FMColors.green)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(FMColors.green.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(FMColors.green.opacity(0.2), lineWidth: 1)
                            )
                            .transition(.opacity)
                        }
 
                        // ── Buttons ──────────────────
                        VStack(spacing: 10) {
 
                            // Share to Feed
                            Button {
                                showShareSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: shareSuccess
                                        ? "checkmark.circle.fill"
                                        : "paperplane.fill"
                                    )
                                    Text(shareSuccess
                                        ? "Shared to Feed ✓"
                                        : "Share to Feed"
                                    )
                                    .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(FMColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(shareSuccess
                                    ? FMColors.green.opacity(0.6)
                                    : FMColors.green
                                )
                                .cornerRadius(12)
                            }
                            .disabled(shareSuccess)
 
                            // See Recipe
                            Button {
                                showRecipe = true
                            } label: {
                                HStack {
                                    Image(systemName: "book.fill")
                                    Text("See Full Recipe")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(FMColors.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(FMColors.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(FMColors.green.opacity(0.3), lineWidth: 1)
                                )
                            }
 
                            // Done
                            Button("Done") {
                                onDismiss()
                                dismiss()
                            }
                            .font(.system(size: 15))
                            .foregroundColor(FMColors.cream.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(FMColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(FMColors.border, lineWidth: 1)
                            )
                            
                            Button {
                                showAR = true
                            } label: {
                                HStack {
                                    Image(systemName: "arkit")
                                    Text("View in AR")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(FMColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "7BB8D8"))
                                .cornerRadius(12)
                            }
                        }
 
                        Color.clear.frame(height: 30)
                    }
                    .padding(18)
                    .padding(.top, 0)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
        .sheet(isPresented: $showRecipe) {
            RecipeSheetView(backendResult: backendResult, image: image)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareToFeedSheet(
                backendResult: backendResult,
                image:         image,
                isSharing:     $isSharing,
                onShare: { caption in
                    shareToFeed(caption: caption)
                }
            )
        }
        .sheet(isPresented: $showAR) {
            FoodARView(
                backendResult: backendResult,
                yoloBBox:      wsManager.yoloBBox,
                foodImage:     cropToYOLO(
                    image:   image,
                    bbox:    wsManager.yoloBBox
                ),
                modelURL: wsManager.model3D?.url
                
            )
        }

    }
    
    private func cropToYOLO(
        image: UIImage,
        bbox: [Double]
    ) -> UIImage {
        guard bbox.count == 4 else { return image }

        let w = image.size.width
        let h = image.size.height

        let cropRect = CGRect(
            x:      bbox[0] * w,
            y:      bbox[1] * h,
            width:  bbox[2] * w,
            height: bbox[3] * h
        )

        guard let cgImage = image.cgImage?.cropping(to: cropRect)
        else { return image }

        return UIImage(cgImage: cgImage)
    }

 
    // ─────────────────────────────────
    // MARK: — Share To Feed
    // ─────────────────────────────────
    private func shareToFeed(caption: String) {
        viewModel.shareToFeed(result: backendResult, imageURL: imageURL, caption: caption)
    }
 
    private var validationColor: Color {
        guard let v = validation else { return FMColors.green }
        switch v.validation_level {
        case "high":   return FMColors.green
        case "medium": return FMColors.yellow
        default:       return FMColors.orange
        }
    }
}
 
// MARK: — Nutrition Grid
struct NutritionGrid: View {
    let result: BackendScanResult
 
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .bottom, spacing: 6) {
                Text("\(result.calories)")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(FMColors.orange)
                Text("kcal")
                    .font(.system(size: 16))
                    .foregroundColor(FMColors.cream.opacity(0.4))
                    .padding(.bottom, 8)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(result.health_score)")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(healthColor(result.health_score))
                    Text("health score")
                        .font(.system(size: 10))
                        .foregroundColor(FMColors.cream25)
                }
            }
 
            HStack(spacing: 1) {
                MacroCell(value: "\(Int(result.protein_g))g", label: "Protein", color: FMColors.green)
                MacroCell(value: "\(Int(result.carbs_g))g",   label: "Carbs",   color: FMColors.yellow)
                MacroCell(value: "\(Int(result.fat_g))g",     label: "Fat",     color: FMColors.orange)
                MacroCell(value: "\(Int(result.fiber_g))g",   label: "Fiber",   color: FMColors.cream50)
            }
            .background(FMColors.border2)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(FMColors.border, lineWidth: 1))
 
            if !result.portion_size.isEmpty {
                HStack {
                    Image(systemName: "scalemass")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream25)
                    Text(result.portion_size)
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream25)
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
 
    private func healthColor(_ score: Int) -> Color {
        if score >= 75 { return FMColors.green }
        if score >= 50 { return FMColors.yellow }
        return FMColors.orange
    }
}
 
struct MacroCell: View {
    let value: String
    let label: String
    let color: Color
 
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(FMColors.cream25)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(FMColors.surface)
    }
}
 
// MARK: — Validation Card
struct ValidationCard: View {
    let validation: ValidationResult
 
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: levelIcon)
                .font(.system(size: 14))
                .foregroundColor(levelColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("Validated by \(validation.validated_by.joined(separator: " + "))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(FMColors.cream.opacity(0.6))
                Text("\(validation.final_confidence)% final confidence · \(validation.validation_level)")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
            Spacer()
        }
        .padding(12)
        .background(FMColors.surface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(levelColor.opacity(0.2), lineWidth: 1))
    }
 
    private var levelColor: Color {
        switch validation.validation_level {
        case "high":   return FMColors.green
        case "medium": return FMColors.yellow
        default:       return FMColors.orange
        }
    }
 
    private var levelIcon: String {
        switch validation.validation_level {
        case "high":   return "checkmark.shield.fill"
        case "medium": return "exclamationmark.shield.fill"
        default:       return "questionmark.circle.fill"
        }
    }
}
 
// MARK: — Ingredients Card
struct IngredientsCard: View {
    let ingredients: [ScanIngredient]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("INGREDIENTS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(FMColors.cream25)
                    .tracking(1.2)
                Spacer()
                Text("\(ingredients.count) detected")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            let maxCalories = ingredients.map(\.calories).max() ?? 1
 
            ForEach(ingredients) { ingredient in
                VStack(spacing: 4) {
                    HStack {
                        Text(ingredient.emoji?.isEmpty == false ? ingredient.emoji! : "🍽️")
                            .font(.system(size: 16))
                        Text(ingredient.name)
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream)
                        Spacer()
                        Text("\(ingredient.grams)g")
                            .font(.system(size: 11))
                            .foregroundColor(FMColors.cream25)
                        Text("\(ingredient.calories) kcal")
                            .font(.system(size: 13, weight: .medium, design: .serif))
                            .foregroundColor(FMColors.orange)
                            .frame(width: 60, alignment: .trailing)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(FMColors.surface2)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(FMColors.orange.opacity(0.6))
                                .frame(width: geo.size.width * CGFloat(ingredient.calories) / CGFloat(maxCalories))
                        }
                    }
                    .frame(height: 3)
                }
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
}
 
// MARK: — Cooking Tip
struct CookingTipCard: View {
    let tip: String
 
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundColor(FMColors.yellow)
                .padding(.top, 2)
            Text(tip)
                .font(.system(size: 13))
                .foregroundColor(FMColors.cream.opacity(0.6))
                .lineSpacing(4)
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(FMColors.yellow.opacity(0.2), lineWidth: 1))
    }
}
 
// MARK: — Allergens
struct AllergensCard: View {
    let allergens: [String]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ALLERGENS")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(FMColors.cream25)
                .tracking(1.2)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(allergens, id: \.self) { allergen in
                        Text("⚠️ \(allergen)")
                            .font(.system(size: 11))
                            .foregroundColor(FMColors.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(FMColors.orange.opacity(0.08))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(FMColors.orange.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(FMColors.border, lineWidth: 1))
    }
}
 
// MARK: — Recipe Sheet
struct RecipeSheetView: View {
    @Environment(\.dismiss) var dismiss
    let backendResult: BackendScanResult
    let image:         UIImage
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 3)
                            .fill(FMColors.cream.opacity(0.2))
                            .frame(width: 40, height: 4)
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
 
                    VStack(alignment: .leading, spacing: 4) {
                        Text(backendResult.dish_name)
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .italic()
                            .foregroundColor(FMColors.cream)
                        Text("Recipe · \(backendResult.cuisine)")
                            .font(.system(size: 12))
                            .foregroundColor(FMColors.cream25)
                    }
                    .padding(.bottom, 16)
 
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(backendResult.recipe_steps) { step in
                            RecipeStepRow(step: step)
                        }
                    }
 
                    if !backendResult.cooking_tip.isEmpty {
                        CookingTipCard(tip: backendResult.cooking_tip)
                            .padding(.top, 14)
                    }
 
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(FMColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(FMColors.green)
                        .cornerRadius(12)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                }
                .padding(18)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
}
 
// MARK: — Recipe Step Row
struct RecipeStepRow: View {
    let step: RecipeStep
 
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(FMColors.green.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text("\(step.step)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(FMColors.green)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(step.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(FMColors.cream)
                    Spacer()
                    Text("\(step.duration_mins) min")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream25)
                }
                Text(step.description)
                    .font(.system(size: 13))
                    .foregroundColor(FMColors.cream.opacity(0.55))
                    .lineSpacing(4)
            }
        }
        .padding(12)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(FMColors.border2, lineWidth: 1))
    }
}
 
// MARK: — Share To Feed Sheet
struct ShareToFeedSheet: View {
 
    @Environment(\.dismiss) var dismiss
 
    let backendResult: BackendScanResult
    let image:         UIImage
    @Binding var isSharing: Bool
    var onShare: (String) -> Void = { _ in }
 
    @State private var caption = ""
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                RoundedRectangle(cornerRadius: 3)
                    .fill(FMColors.cream.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
 
                Text("Share to Feed")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(FMColors.cream)
                    .padding(.bottom, 16)
 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
 
                        // Preview card
                        HStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(10)
 
                            VStack(alignment: .leading, spacing: 4) {
                                Text(backendResult.dish_name)
                                    .font(.system(size: 15, weight: .semibold, design: .serif))
                                    .italic()
                                    .foregroundColor(FMColors.cream)
                                HStack(spacing: 8) {
                                    Text("🔥 \(backendResult.calories) kcal")
                                    Text("💪 \(Int(backendResult.protein_g))g")
                                    Text("🍞 \(Int(backendResult.carbs_g))g")
                                }
                                .font(.system(size: 11))
                                .foregroundColor(FMColors.cream.opacity(0.5))
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(FMColors.surface)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(FMColors.border, lineWidth: 1))
 
                        // Caption input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CAPTION")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(FMColors.cream25)
                                .tracking(1.2)
 
                            ZStack(alignment: .topLeading) {
                                if caption.isEmpty {
                                    Text("Add a caption...")
                                        .font(.system(size: 14))
                                        .foregroundColor(FMColors.cream.opacity(0.25))
                                        .padding(12)
                                }
                                TextEditor(text: $caption)
                                    .font(.system(size: 14))
                                    .foregroundColor(FMColors.cream)
                                    .frame(minHeight: 80)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                            }
                            .background(FMColors.surface)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(FMColors.border, lineWidth: 1))
                        }
 
                        // Share button
                        Button {
                            onShare(caption)
                            dismiss()
                        } label: {
                            HStack {
                                if isSharing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: FMColors.background))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSharing ? "Sharing..." : "Share Now")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(FMColors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(FMColors.green)
                            .cornerRadius(12)
                        }
                        .disabled(isSharing)
 
                        Button("Cancel") { dismiss() }
                            .font(.system(size: 14))
                            .foregroundColor(FMColors.cream.opacity(0.4))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
 
#Preview {
    Text("ScanResultView")
}

extension UIImage {
    func normalizedImage() -> UIImage {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}
