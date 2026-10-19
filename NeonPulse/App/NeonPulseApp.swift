import SwiftUI

@main
struct NeonPulseApp: App {
    init() {
        // Warm up haptics and sound engine on launch
        HapticManager.shared.prepare()
        _ = SoundEngine.shared
    }
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .preferredColorScheme(.dark)
                .statusBar(hidden: true)
        }
    }
}
