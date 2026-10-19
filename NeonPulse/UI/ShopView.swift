import SwiftUI

public struct ShopView: View {
    @ObservedObject var skinManager = SkinManager.shared
    @ObservedObject var gameState = GameState.shared
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.04, blue: 0.1).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Header Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CYBER CORE SHOP")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("NOYAUX AVEC CAPACITÉS SPÉCIALES")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    
                    Spacer()
                    
                    // Balance
                    HStack(spacing: 6) {
                        Image(systemName: "rhombus.fill")
                            .foregroundColor(.cyan)
                        Text("\(gameState.totalBits)")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Skins Scroll
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(skinManager.allSkins) { skin in
                            SkinRowView(skin: skin)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

private struct SkinRowView: View {
    let skin: SkinItem
    @ObservedObject var skinManager = SkinManager.shared
    @ObservedObject var gameState = GameState.shared
    
    var isEquipped: Bool {
        skinManager.selectedSkinId == skin.id
    }
    
    var isUnlocked: Bool {
        skinManager.isUnlocked(skin)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Skin Preview Icon
            ZStack {
                Circle()
                    .fill(Color(hex: skin.coreHex) ?? .cyan)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color(hex: skin.glowHex) ?? .pink, radius: 8)
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 44, height: 44)
            }
            .padding(.leading, 6)
            
            // Details & Perk
            VStack(alignment: .leading, spacing: 3) {
                Text(skin.name)
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(skin.perk)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                    .lineLimit(1)
                
                Text(skin.description)
                    .font(.system(size: 10, design: .default))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Action Button
            if isEquipped {
                Text("ÉQUIPÉ")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(8)
            } else if isUnlocked {
                Button(action: {
                    HapticManager.shared.lightTap()
                    skinManager.selectSkin(skin)
                }) {
                    Text("ÉQUIPER")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.cyan)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    if skinManager.unlockSkin(skin) {
                        HapticManager.shared.hyperdriveTrigger()
                    } else {
                        HapticManager.shared.crashFeedback()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "rhombus.fill")
                            .font(.system(size: 10))
                        Text("\(skin.price)")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(gameState.totalBits >= skin.price ? .black : .gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(gameState.totalBits >= skin.price ? Color.yellow : Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isEquipped ? Color.cyan : Color.white.opacity(0.08), lineWidth: isEquipped ? 2 : 1)
                )
        )
    }
}

// SwiftUI Color hex initializer helper
extension Color {
    init?(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        guard cString.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            .sRGB,
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
}
