import SwiftUI

public struct GameOverView: View {
    @ObservedObject var gameState = GameState.shared
    var onRetry: () -> Void
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.88)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 18) {
                Spacer()
                
                // Header
                VStack(spacing: 4) {
                    Text("SYSTEM CRASH")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.red)
                        .shadow(color: .red, radius: 12)
                    
                    if gameState.score >= gameState.highScore && gameState.score > 0 {
                        Text("★ NOUVEAU RECORD ! ★")
                            .font(.system(size: 14, weight: .heavy, design: .monospaced))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow, radius: 8)
                    }
                }
                
                // Score Box
                VStack(spacing: 6) {
                    Text("\(gameState.score)")
                        .font(.system(size: 58, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .cyan, radius: 14)
                    
                    Text("MEILLEUR SCORE: \(gameState.highScore)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cyan.opacity(0.3), lineWidth: 1.5))
                )
                .padding(.horizontal, 28)
                
                // Level & XP Progression Bar
                VStack(spacing: 6) {
                    HStack {
                        Text("NIVEAU \(gameState.playerLevel)")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Text("+\(gameState.xpEarnedThisRun) XP")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 7)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [.yellow, .green], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * CGFloat(min(1.0, Double(gameState.currentXP) / Double(max(1, gameState.xpToNextLevel)))), height: 7)
                        }
                    }
                    .frame(height: 7)
                }
                .padding(.horizontal, 32)
                
                // Run Statistics Breakdown
                HStack(spacing: 16) {
                    StatCard(title: "GRAZES", value: "\(gameState.grazesThisRun)", color: .yellow)
                    StatCard(title: "COMBO", value: "\(gameState.combo)x", color: .pink)
                    StatCard(title: "BITS", value: "+\(gameState.bitsCollectedThisRun)", color: .cyan)
                    StatCard(title: "ZONE", value: "\(gameState.currentZone)", color: .purple)
                }
                .padding(.horizontal, 28)
                
                // Primary Action Button (RETRY)
                Button(action: {
                    HapticManager.shared.rigidThump()
                    onRetry()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .bold))
                        Text("REJOUER")
                            .font(.system(size: 19, weight: .black, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundColor(.black)
                    .background(
                        LinearGradient(colors: [Color.cyan, Color(red: 0.0, green: 0.8, blue: 1.0)], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    .shadow(color: .cyan.opacity(0.8), radius: 12)
                }
                .padding(.horizontal, 28)
                .padding(.top, 4)
                
                // Secondary Action Buttons (Shop, Crates & Missions)
                HStack(spacing: 10) {
                    Button(action: {
                        HapticManager.shared.buttonClick()
                        gameState.showShop = true
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "cart.fill")
                            Text("SHOP")
                        }
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.pink.opacity(0.5), lineWidth: 1))
                    }
                    
                    Button(action: {
                        HapticManager.shared.buttonClick()
                        gameState.showCrates = true
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "cube.fill")
                            Text("CAISSES")
                        }
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow.opacity(0.6), lineWidth: 1))
                    }
                    
                    Button(action: {
                        HapticManager.shared.buttonClick()
                        gameState.showMissions = true
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "target")
                            Text("QUÊTES")
                        }
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cyan.opacity(0.5), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 28)
                
                // Settings Row (Sound & Haptics)
                HStack(spacing: 24) {
                    Button(action: { gameState.toggleSound() }) {
                        Image(systemName: gameState.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundColor(gameState.soundEnabled ? .cyan : .gray)
                            .font(.system(size: 18))
                    }
                    
                    Button(action: { gameState.toggleHaptics() }) {
                        Image(systemName: gameState.hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            .foregroundColor(gameState.hapticsEnabled ? .cyan : .gray)
                            .font(.system(size: 18))
                    }
                }
                .padding(.top, 2)
                
                Spacer()
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(red: 0.14, green: 0.14, blue: 0.18))
        .cornerRadius(10)
    }
}
