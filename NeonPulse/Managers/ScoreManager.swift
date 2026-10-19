import Foundation

public struct Mission: Identifiable {
    public let id: String
    public let title: String
    public let target: Int
    public let reward: Int
    public var currentProgress: Int
    public var isClaimed: Bool
    
    public var isCompleted: Bool {
        return currentProgress >= target
    }
}

public class ScoreManager: ObservableObject {
    public static let shared = ScoreManager()
    
    @Published public var missions: [Mission] = []
    
    private init() {
        loadMissions()
    }
    
    public func loadMissions() {
        let grazeProgress = UserDefaults.standard.integer(forKey: "NP_Mission_Graze")
        let grazeClaimed = UserDefaults.standard.bool(forKey: "NP_Mission_Graze_Claimed")
        
        let comboProgress = UserDefaults.standard.integer(forKey: "NP_Mission_Combo")
        let comboClaimed = UserDefaults.standard.bool(forKey: "NP_Mission_Combo_Claimed")
        
        let bitsProgress = UserDefaults.standard.integer(forKey: "NP_Mission_Bits")
        let bitsClaimed = UserDefaults.standard.bool(forKey: "NP_Mission_Bits_Claimed")
        
        let hyperProgress = UserDefaults.standard.integer(forKey: "NP_Mission_Hyper")
        let hyperClaimed = UserDefaults.standard.bool(forKey: "NP_Mission_Hyper_Claimed")
        
        missions = [
            Mission(id: "m_graze", title: "Graze 15 Obstacles", target: 15, reward: 150, currentProgress: grazeProgress, isClaimed: grazeClaimed),
            Mission(id: "m_combo", title: "Achieve a 25x Combo", target: 25, reward: 200, currentProgress: comboProgress, isClaimed: comboClaimed),
            Mission(id: "m_bits", title: "Harvest 100 Cyber Bits", target: 100, reward: 180, currentProgress: bitsProgress, isClaimed: bitsClaimed),
            Mission(id: "m_hyper", title: "Trigger Hyperdrive 2 Times", target: 2, reward: 160, currentProgress: hyperProgress, isClaimed: hyperClaimed)
        ]
    }
    
    public func recordRunStats(grazes: Int, maxCombo: Int, bits: Int, hyperCount: Int) {
        let oldGraze = UserDefaults.standard.integer(forKey: "NP_Mission_Graze")
        UserDefaults.standard.set(oldGraze + grazes, forKey: "NP_Mission_Graze")
        
        let oldCombo = UserDefaults.standard.integer(forKey: "NP_Mission_Combo")
        if maxCombo > oldCombo {
            UserDefaults.standard.set(maxCombo, forKey: "NP_Mission_Combo")
        }
        
        let oldBits = UserDefaults.standard.integer(forKey: "NP_Mission_Bits")
        UserDefaults.standard.set(oldBits + bits, forKey: "NP_Mission_Bits")
        
        let oldHyper = UserDefaults.standard.integer(forKey: "NP_Mission_Hyper")
        UserDefaults.standard.set(oldHyper + hyperCount, forKey: "NP_Mission_Hyper")
        
        loadMissions()
    }
    
    public func claimReward(missionId: String) {
        guard let index = missions.firstIndex(where: { $0.id == missionId && $0.isCompleted && !$0.isClaimed }) else { return }
        
        let reward = missions[index].reward
        GameState.shared.totalBits += reward
        UserDefaults.standard.set(GameState.shared.totalBits, forKey: "NP_TotalBits")
        UserDefaults.standard.set(true, forKey: "NP_Mission_\(missionId)_Claimed")
        
        missions[index].isClaimed = true
        HapticManager.shared.hyperdriveTrigger()
    }
}
