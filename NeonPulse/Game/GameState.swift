import SwiftUI
import Combine

public enum GameModePhase {
    case menu
    case playing
    case paused
    case gameOver
}

public class GameState: ObservableObject {
    public static let shared = GameState()
    
    @Published public var phase: GameModePhase = .menu
    @Published public var score: Int = 0
    @Published public var highScore: Int = 0
    @Published public var combo: Int = 1
    @Published public var comboMultiplier: Double = 1.0
    @Published public var overdriveProgress: Double = 0.0 // 0.0 to 1.0
    @Published public var isHyperdrive: Bool = false
    @Published public var hyperdriveTimeRemaining: Double = 0.0
    
    @Published public var bitsCollectedThisRun: Int = 0
    @Published public var totalBits: Int = 0
    @Published public var grazesThisRun: Int = 0
    
    @Published public var showShop: Bool = false
    @Published public var showMissions: Bool = false
    @Published public var soundEnabled: Bool = true
    @Published public var hapticsEnabled: Bool = true
    
    @Published public var comboBannerText: String = ""
    @Published public var showComboBanner: Bool = false
    
    private init() {
        self.highScore = UserDefaults.standard.integer(forKey: "NP_HighScore")
        self.totalBits = UserDefaults.standard.integer(forKey: "NP_TotalBits")
        if !UserDefaults.standard.bool(forKey: "NP_HasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "NP_HasLaunchedBefore")
            UserDefaults.standard.set(100, forKey: "NP_TotalBits") // Starter gift
            self.totalBits = 100
        }
        self.soundEnabled = UserDefaults.standard.object(forKey: "NP_SoundEnabled") as? Bool ?? true
        self.hapticsEnabled = UserDefaults.standard.object(forKey: "NP_HapticsEnabled") as? Bool ?? true
    }
    
    public func startNewGame() {
        score = 0
        combo = 1
        comboMultiplier = 1.0
        overdriveProgress = 0.0
        isHyperdrive = false
        hyperdriveTimeRemaining = 0.0
        bitsCollectedThisRun = 0
        grazesThisRun = 0
        showComboBanner = false
        comboBannerText = ""
        phase = .playing
    }
    
    public func addScore(_ points: Int) {
        let earned = Int(Double(points) * comboMultiplier)
        score += earned
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "NP_HighScore")
        }
    }
    
    public func incrementCombo() {
        combo += 1
        comboMultiplier = min(5.0, 1.0 + Double(combo) * 0.1)
        
        if combo == 5 {
            triggerComboBanner("5x COMBO!")
        } else if combo == 10 {
            triggerComboBanner("10x SUPER!")
        } else if combo == 25 {
            triggerComboBanner("25x ULTRA!")
        } else if combo == 50 {
            triggerComboBanner("50x UNSTOPPABLE!")
        } else if combo == 100 {
            triggerComboBanner("100x GODLIKE!!")
        }
    }
    
    public func resetCombo() {
        combo = 1
        comboMultiplier = 1.0
    }
    
    private func triggerComboBanner(_ text: String) {
        comboBannerText = text
        showComboBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            if self?.comboBannerText == text {
                self?.showComboBanner = false
            }
        }
    }
    
    public func addOverdrive(amount: Double) {
        if isHyperdrive { return }
        overdriveProgress = min(1.0, overdriveProgress + amount)
        if overdriveProgress >= 1.0 {
            activateHyperdrive()
        }
    }
    
    public func activateHyperdrive() {
        isHyperdrive = true
        overdriveProgress = 1.0
        hyperdriveTimeRemaining = 7.0
        comboMultiplier *= 2.0
        triggerComboBanner("⚡ HYPERDRIVE! ⚡")
    }
    
    public func endHyperdrive() {
        isHyperdrive = false
        overdriveProgress = 0.0
        comboMultiplier = max(1.0, comboMultiplier / 2.0)
    }
    
    public func collectBit() {
        bitsCollectedThisRun += 1
        totalBits += 1
        UserDefaults.standard.set(totalBits, forKey: "NP_TotalBits")
        addScore(25)
        addOverdrive(amount: 0.06)
    }
    
    public func registerGraze() {
        grazesThisRun += 1
        addScore(100)
        incrementCombo()
        addOverdrive(amount: 0.10)
    }
    
    public func spendBits(_ amount: Int) -> Bool {
        if totalBits >= amount {
            totalBits -= amount
            UserDefaults.standard.set(totalBits, forKey: "NP_TotalBits")
            return true
        }
        return false
    }
    
    public func toggleSound() {
        soundEnabled.toggle()
        UserDefaults.standard.set(soundEnabled, forKey: "NP_SoundEnabled")
    }
    
    public func toggleHaptics() {
        hapticsEnabled.toggle()
        UserDefaults.standard.set(hapticsEnabled, forKey: "NP_HapticsEnabled")
    }
    
    public func endGame() {
        phase = .gameOver
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "NP_HighScore")
        }
        // Save stats
        let totalRuns = UserDefaults.standard.integer(forKey: "NP_TotalRuns") + 1
        UserDefaults.standard.set(totalRuns, forKey: "NP_TotalRuns")
        let totalGrazes = UserDefaults.standard.integer(forKey: "NP_TotalGrazes") + grazesThisRun
        UserDefaults.standard.set(totalGrazes, forKey: "NP_TotalGrazes")
    }
}
