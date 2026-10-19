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
    
    // Power-Ups
    @Published public var hasShield: Bool = false
    @Published public var magnetTimer: Double = 0.0
    @Published public var chronoTimer: Double = 0.0
    @Published public var bombsAvailable: Int = 1
    
    // Zones
    @Published public var currentZone: Int = 1
    @Published public var zoneName: String = "CYBER HORIZON"
    
    // Metagame XP & Leveling
    @Published public var playerLevel: Int = 1
    @Published public var currentXP: Int = 0
    @Published public var xpToNextLevel: Int = 500
    @Published public var xpEarnedThisRun: Int = 0
    
    @Published public var bitsCollectedThisRun: Int = 0
    @Published public var totalBits: Int = 0
    @Published public var grazesThisRun: Int = 0
    
    @Published public var showShop: Bool = false
    @Published public var showMissions: Bool = false
    @Published public var showCrates: Bool = false
    @Published public var soundEnabled: Bool = true
    @Published public var hapticsEnabled: Bool = true
    
    @Published public var comboBannerText: String = ""
    @Published public var showComboBanner: Bool = false
    
    private init() {
        self.highScore = UserDefaults.standard.integer(forKey: "NP_HighScore")
        self.totalBits = UserDefaults.standard.integer(forKey: "NP_TotalBits")
        self.playerLevel = max(1, UserDefaults.standard.integer(forKey: "NP_PlayerLevel"))
        self.currentXP = UserDefaults.standard.integer(forKey: "NP_CurrentXP")
        self.xpToNextLevel = self.playerLevel * 500
        
        if !UserDefaults.standard.bool(forKey: "NP_HasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "NP_HasLaunchedBefore")
            UserDefaults.standard.set(250, forKey: "NP_TotalBits") // Generous starter gift
            self.totalBits = 250
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
        xpEarnedThisRun = 0
        showComboBanner = false
        comboBannerText = ""
        currentZone = 1
        zoneName = "CYBER HORIZON"
        
        // Power-ups reset
        magnetTimer = 0.0
        chronoTimer = 0.0
        bombsAvailable = 1
        
        // Skin perk check
        if SkinManager.shared.currentSkin.id == "skin_prismatic" {
            hasShield = true
        } else {
            hasShield = false
        }
        
        phase = .playing
    }
    
    public func addScore(_ points: Int) {
        let earned = Int(Double(points) * comboMultiplier)
        score += earned
        addXP(earned / 3)
        checkZoneTransition()
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "NP_HighScore")
        }
    }
    
    private func checkZoneTransition() {
        let previousZone = currentZone
        if score >= 8000 {
            currentZone = 5
            zoneName = "QUANTUM SINGULARITY"
        } else if score >= 4500 {
            currentZone = 4
            zoneName = "SOLAR INFERNO"
        } else if score >= 2200 {
            currentZone = 3
            zoneName = "MATRIX MAINFRAME"
        } else if score >= 800 {
            currentZone = 2
            zoneName = "SYNTHWAVE SUNSET"
        } else {
            currentZone = 1
            zoneName = "CYBER HORIZON"
        }
        
        if currentZone != previousZone {
            triggerComboBanner("ENTERING \(zoneName)!")
            HapticManager.shared.hyperdriveTrigger()
            SoundEngine.shared.playZoneShift()
        }
    }
    
    public func incrementCombo() {
        combo += 1
        comboMultiplier = min(6.0, 1.0 + Double(combo) * 0.12)
        
        if combo == 5 {
            triggerComboBanner("5x COMBO!")
        } else if combo == 10 {
            triggerComboBanner("10x SUPER!")
        } else if combo == 25 {
            triggerComboBanner("25x ULTRA!")
        } else if combo == 50 {
            triggerComboBanner("50x UNSTOPPABLE!")
        } else if combo == 100 {
            triggerComboBanner("⚡ 100x GODLIKE!! ⚡")
        }
    }
    
    public func resetCombo() {
        combo = 1
        comboMultiplier = 1.0
    }
    
    public func triggerComboBanner(_ text: String) {
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
        var rate = amount
        if SkinManager.shared.currentSkin.id == "skin_solar" {
            rate *= 1.4 // Solar skin charges 40% faster
        }
        overdriveProgress = min(1.0, overdriveProgress + rate)
        if overdriveProgress >= 1.0 {
            activateHyperdrive()
        }
    }
    
    public func activateHyperdrive() {
        isHyperdrive = true
        overdriveProgress = 1.0
        hyperdriveTimeRemaining = 7.5
        comboMultiplier *= 2.0
        triggerComboBanner("⚡ HYPERDRIVE! ⚡")
        HapticManager.shared.hyperdriveTrigger()
        SoundEngine.shared.playHyperdrive()
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
        addScore(30)
        addOverdrive(amount: 0.06)
        addXP(15)
    }
    
    public func registerGraze() {
        grazesThisRun += 1
        var points = 120
        if SkinManager.shared.currentSkin.id == "skin_matrix" {
            points = 250 // Matrix skin bonus
        }
        addScore(points)
        incrementCombo()
        addOverdrive(amount: 0.12)
        addXP(30)
    }
    
    public func activatePowerUp(_ type: PowerUpType) {
        switch type {
        case .shield:
            hasShield = true
            triggerComboBanner("🛡 BOUCLIER ACTIF!")
        case .magnet:
            magnetTimer = 8.0
            triggerComboBanner("🧲 HYPER AIMANT!")
        case .chrono:
            chronoTimer = 6.0
            triggerComboBanner("⏱ TEMPS RALENTI!")
        case .bomb:
            bombsAvailable += 1
            triggerComboBanner("⚡ BOMBE EMP +1 (DOUBLE TAP)!")
        }
        HapticManager.shared.rigidThump()
        SoundEngine.shared.playPowerUp()
    }
    
    public func addXP(_ amount: Int) {
        currentXP += amount
        xpEarnedThisRun += amount
        if currentXP >= xpToNextLevel {
            currentXP -= xpToNextLevel
            playerLevel += 1
            xpToNextLevel = playerLevel * 500
            UserDefaults.standard.set(playerLevel, forKey: "NP_PlayerLevel")
            // Level up reward
            totalBits += 100
            UserDefaults.standard.set(totalBits, forKey: "NP_TotalBits")
            triggerComboBanner("★ NIVEAU \(playerLevel) ATTEINT ! (+100 BITS) ★")
            HapticManager.shared.hyperdriveTrigger()
        }
        UserDefaults.standard.set(currentXP, forKey: "NP_CurrentXP")
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
        let totalRuns = UserDefaults.standard.integer(forKey: "NP_TotalRuns") + 1
        UserDefaults.standard.set(totalRuns, forKey: "NP_TotalRuns")
        let totalGrazes = UserDefaults.standard.integer(forKey: "NP_TotalGrazes") + grazesThisRun
        UserDefaults.standard.set(totalGrazes, forKey: "NP_TotalGrazes")
    }
}
