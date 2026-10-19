import SwiftUI

public struct HUDView: View {
    @ObservedObject var gameState = GameState.shared
    
    public var body: some View {
        VStack(spacing: 8) {
            // Top Bar
            HStack(alignment: .center) {
                // Score & Best
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(gameState.score)")
                        .font(.system(size: 38, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.8), radius: 8, x: 0, y: 0)
                    
                    HStack(spacing: 8) {
                        Text("BEST: \(gameState.highScore)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan.opacity(0.8))
                        
                        Text("LVL \(gameState.playerLevel)")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Bits Counter & Zone
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "rhombus.fill")
                            .foregroundColor(.cyan)
                            .font(.system(size: 16))
                            .shadow(color: .cyan, radius: 4)
                        
                        Text("\(gameState.totalBits)")
                            .font(.system(size: 18, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.85))
                            .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                    )
                    
                    Text("ZONE \(gameState.currentZone)")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(.pink)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            
            // Overdrive / Hyperdrive Energy Bar
            VStack(spacing: 4) {
                HStack {
                    Text(gameState.isHyperdrive ? "HYPERDRIVE ACTIVE" : "OVERDRIVE CHARGE")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(gameState.isHyperdrive ? .yellow : .cyan)
                    
                    Spacer()
                    
                    if gameState.combo > 1 {
                        Text(String(format: "%.1fx BOOST", gameState.comboMultiplier))
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.pink)
                    }
                }
                .padding(.horizontal, 22)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: gameState.isHyperdrive ? [.pink, .yellow, .cyan] : [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * CGFloat(gameState.overdriveProgress)), height: 10)
                            .shadow(color: gameState.isHyperdrive ? .yellow : .cyan, radius: gameState.isHyperdrive ? 8 : 4)
                            .animation(.easeOut(duration: 0.2), value: gameState.overdriveProgress)
                    }
                }
                .frame(height: 10)
                .padding(.horizontal, 20)
            }
            
            // Active Power-Ups Row
            HStack(spacing: 12) {
                if gameState.hasShield {
                    HStack(spacing: 4) {
                        Text("🛡")
                        Text("BOUCLIER")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.cyan.opacity(0.15))
                    .cornerRadius(6)
                }
                
                if gameState.magnetTimer > 0 {
                    HStack(spacing: 4) {
                        Text("🧲")
                        Text(String(format: "%.1fs", gameState.magnetTimer))
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(6)
                }
                
                if gameState.chronoTimer > 0 {
                    HStack(spacing: 4) {
                        Text("⏱")
                        Text(String(format: "%.1fs", gameState.chronoTimer))
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(6)
                }
                
                if gameState.bombsAvailable > 0 {
                    HStack(spacing: 4) {
                        Text("⚡")
                        Text("EMP: \(gameState.bombsAvailable)")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(6)
                }
                
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 4)
            
            // Dynamic Combo Popup Banner
            if gameState.showComboBanner {
                Text(gameState.comboBannerText)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .pink, radius: 10)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 12)
            }
            
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
