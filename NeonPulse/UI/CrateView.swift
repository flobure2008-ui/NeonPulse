import SwiftUI

public struct CrateView: View {
    @ObservedObject var gameState = GameState.shared
    @ObservedObject var skinManager = SkinManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSpinning: Bool = false
    @State private var resultMessage: String = ""
    @State private var rewardType: String = ""
    @State private var showResult: Bool = false
    
    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.12).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CYBER CRATES")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("DÉVERROUILLE DES SKINS & BITS RARES")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
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
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer()
                
                // Holographic Crate Box Animation
                ZStack {
                    // Outer aura
                    Circle()
                        .fill(RadialGradient(colors: [.purple.opacity(0.5), .clear], center: .center, startRadius: 20, endRadius: 140))
                        .frame(width: 280, height: 280)
                    
                    // Rotating cyber rings
                    Circle()
                        .stroke(LinearGradient(colors: [.cyan, .pink], startPoint: .top, endPoint: .bottom), lineWidth: 3)
                        .frame(width: 190, height: 190)
                        .rotationEffect(.degrees(isSpinning ? 720 : 0))
                        .animation(isSpinning ? .easeInOut(duration: 1.8) : .linear(duration: 8).repeatForever(autoreverses: false), value: isSpinning)
                    
                    // Center Crate Icon
                    VStack(spacing: 8) {
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .yellow.opacity(0.8), radius: 16)
                            .scaleEffect(isSpinning ? 1.25 : 1.0)
                            .animation(.easeInOut(duration: 0.3).repeatCount(6, autoreverses: true), value: isSpinning)
                        
                        Text("MYSTERY CRATE")
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                
                // Result Pop-up
                if showResult {
                    VStack(spacing: 6) {
                        Text(rewardType)
                            .font(.system(size: 14, weight: .heavy, design: .monospaced))
                            .foregroundColor(.yellow)
                        Text(resultMessage)
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.3)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pink, lineWidth: 1.5)))
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Open Button
                Button(action: {
                    openCrate()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                        Text("OUVRIR (250 BITS)")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(
                        gameState.totalBits >= 250 ?
                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.gray, .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    .shadow(color: gameState.totalBits >= 250 ? .yellow.opacity(0.6) : .clear, radius: 10)
                }
                .disabled(gameState.totalBits < 250 || isSpinning)
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }
    
    private func openCrate() {
        guard gameState.spendBits(250) else { return }
        isSpinning = true
        showResult = false
        HapticManager.shared.hyperdriveTrigger()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isSpinning = false
            determineReward()
            showResult = true
        }
    }
    
    private func determineReward() {
        // Find locked skins
        let lockedSkins = skinManager.allSkins.filter { !skinManager.isUnlocked($0) }
        let roll = Int.random(in: 1...100)
        
        if roll <= 30 && !lockedSkins.isEmpty {
            // Unlock a random skin!
            let wonSkin = lockedSkins.randomElement()!
            skinManager.unlockedSkinIds.insert(wonSkin.id)
            UserDefaults.standard.set(Array(skinManager.unlockedSkinIds), forKey: "NP_UnlockedSkins")
            skinManager.selectSkin(wonSkin)
            
            rewardType = "★ SKIN LÉGENDAIRE DÉBLOQUÉ ! ★"
            resultMessage = wonSkin.name.uppercased()
            SoundEngine.shared.playHyperdrive()
            HapticManager.shared.hyperdriveTrigger()
        } else if roll <= 60 {
            // Big Bits Jackpot
            let bonus = Int.random(in: 350...700)
            gameState.totalBits += bonus
            UserDefaults.standard.set(gameState.totalBits, forKey: "NP_TotalBits")
            
            rewardType = "JACKPOT DE BITS !"
            resultMessage = "+\(bonus) CYBER BITS"
            SoundEngine.shared.playPowerUp()
            HapticManager.shared.heavyThud()
        } else {
            // Standard bits
            let bonus = Int.random(in: 150...300)
            gameState.totalBits += bonus
            UserDefaults.standard.set(gameState.totalBits, forKey: "NP_TotalBits")
            
            rewardType = "RÉCOMPENSE"
            resultMessage = "+\(bonus) CYBER BITS"
            SoundEngine.shared.playCollectBit(combo: 1)
            HapticManager.shared.mediumTap()
        }
    }
}
