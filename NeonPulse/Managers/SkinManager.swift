import SwiftUI
import SpriteKit

public struct SkinItem: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let perk: String
    public let price: Int
    public let coreHex: String
    public let glowHex: String
    public let trailHex: String
    
    public var coreColor: UIColor {
        return UIColor(hex: coreHex) ?? .cyan
    }
    
    public var glowColor: UIColor {
        return UIColor(hex: glowHex) ?? .systemPink
    }
    
    public var trailColor: UIColor {
        return UIColor(hex: trailHex) ?? .blue
    }
}

public class SkinManager: ObservableObject {
    public static let shared = SkinManager()
    
    public let allSkins: [SkinItem] = [
        SkinItem(
            id: "skin_cyan",
            name: "Cyber Pulse",
            description: "Le stabilisateur quantique originel.",
            perk: "⚡ Équilibre parfait & maniabilité accrue",
            price: 0,
            coreHex: "#00F5FF",
            glowHex: "#0077FE",
            trailHex: "#00FFFF"
        ),
        SkinItem(
            id: "skin_solar",
            name: "Solar Flare",
            description: "Forgé dans le coeur d'une supernova.",
            perk: "🔥 Jauge Overdrive se charge +40% plus vite",
            price: 200,
            coreHex: "#FF9500",
            glowHex: "#FFD60A",
            trailHex: "#FF5E00"
        ),
        SkinItem(
            id: "skin_void",
            name: "Void Phantom",
            description: "Manipule la matière noire et les trous de ver.",
            perk: "🧲 Rayon magnétique de récolte permanent +50%",
            price: 450,
            coreHex: "#AF52DE",
            glowHex: "#BF5AF2",
            trailHex: "#5E5CE6"
        ),
        SkinItem(
            id: "skin_matrix",
            name: "Matrix Glitch",
            description: "Un virus renégat échappé du Cyberespace.",
            perk: "💻 Score des Frôlements (Grazes) x2 (+250 pts)",
            price: 750,
            coreHex: "#30D158",
            glowHex: "#34C759",
            trailHex: "#00FF66"
        ),
        SkinItem(
            id: "skin_inferno",
            name: "Inferno Core",
            description: "Plasma surchauffé qui désintègre la réalité.",
            perk: "💥 Démarre avec 2 Bombes EMP au lieu de 1",
            price: 1200,
            coreHex: "#FF3B30",
            glowHex: "#FF453A",
            trailHex: "#FF6B00"
        ),
        SkinItem(
            id: "skin_prismatic",
            name: "Prismatic Apex",
            description: "La relique ultime transcendant le spectre lumineux.",
            perk: "🛡️ Bouclier de Phase protecteur gratuit à chaque run",
            price: 2500,
            coreHex: "#FFFFFF",
            glowHex: "#00F5FF",
            trailHex: "#FF007F"
        )
    ]
    
    @Published public var selectedSkinId: String = "skin_cyan"
    @Published public var unlockedSkinIds: Set<String> = ["skin_cyan"]
    
    private init() {
        if let savedSelected = UserDefaults.standard.string(forKey: "NP_SelectedSkin") {
            selectedSkinId = savedSelected
        }
        if let savedUnlocked = UserDefaults.standard.stringArray(forKey: "NP_UnlockedSkins") {
            unlockedSkinIds = Set(savedUnlocked)
        }
        unlockedSkinIds.insert("skin_cyan")
    }
    
    public var currentSkin: SkinItem {
        allSkins.first(where: { $0.id == selectedSkinId }) ?? allSkins[0]
    }
    
    public func isUnlocked(_ skin: SkinItem) -> Bool {
        return unlockedSkinIds.contains(skin.id)
    }
    
    public func unlockSkin(_ skin: SkinItem) -> Bool {
        guard !isUnlocked(skin) else { return true }
        if GameState.shared.spendBits(skin.price) {
            unlockedSkinIds.insert(skin.id)
            UserDefaults.standard.set(Array(unlockedSkinIds), forKey: "NP_UnlockedSkins")
            selectSkin(skin)
            return true
        }
        return false
    }
    
    public func selectSkin(_ skin: SkinItem) {
        guard isUnlocked(skin) else { return }
        selectedSkinId = skin.id
        UserDefaults.standard.set(selectedSkinId, forKey: "NP_SelectedSkin")
        objectWillChange.send()
    }
}

// UIColor hex helper
extension UIColor {
    convenience init?(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        guard cString.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
