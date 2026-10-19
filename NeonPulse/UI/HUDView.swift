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
                    
                    Text("BEST: \(gameState.highScore)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan.opacity(0.8))
                }
                
                Spacer()
                
                // Bits Counter
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
                        .fill(Color(white: 0.12).opacity(0.8))
                        .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 48) // Safe area top
            
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
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 10)
                        
                        // Fill bar
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
            
            // Dynamic Combo Popup Banner
            if gameState.showComboBanner {
                Text(gameState.comboBannerText)
                    .font(.system(size: 26, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .pink, radius: 10)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 16)
            }
            
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
