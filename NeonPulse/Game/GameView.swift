import SwiftUI
import SpriteKit

public struct GameView: View {
    @ObservedObject var gameState = GameState.shared
    @ObservedObject var skinManager = SkinManager.shared
    
    @State private var scene: GameScene?
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit Scene
                if let scene = scene {
                    SpriteView(
                        scene: scene,
                        isPaused: gameState.phase == .paused,
                        preferredFramesPerSecond: 120
                    )
                    .edgesIgnoringSafeArea(.all)
                } else {
                    Color.black.edgesIgnoringSafeArea(.all)
                }
                
                // Active HUD
                if gameState.phase == .playing {
                    HUDView()
                }
                
                // Game Over Overlay
                if gameState.phase == .gameOver {
                    GameOverView(onRetry: {
                        scene?.startSession()
                    })
                    .transition(.opacity)
                }
            }
            .onAppear {
                let newScene = GameScene(size: geometry.size)
                newScene.scaleMode = .resizeFill
                self.scene = newScene
            }
            .onChange(of: skinManager.selectedSkinId) { _ in
                // Skin changed in shop
                if let scene = scene {
                    scene.startSession()
                }
            }
            .sheet(isPresented: $gameState.showShop) {
                ShopView()
            }
            .sheet(isPresented: $gameState.showMissions) {
                MissionsView()
            }
            .sheet(isPresented: $gameState.showCrates) {
                CrateView()
            }
        }
    }
}
