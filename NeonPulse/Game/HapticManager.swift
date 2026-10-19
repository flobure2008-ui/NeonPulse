import UIKit

public class HapticManager {
    public static let shared = HapticManager()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let notifyGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        prepare()
    }
    
    public func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        rigidGenerator.prepare()
        notifyGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    public func lightTap() {
        guard GameState.shared.hapticsEnabled else { return }
        lightGenerator.impactOccurred()
    }
    
    public func mediumTap() {
        guard GameState.shared.hapticsEnabled else { return }
        mediumGenerator.impactOccurred()
    }
    
    public func heavyThud() {
        guard GameState.shared.hapticsEnabled else { return }
        heavyGenerator.impactOccurred()
    }
    
    public func rigidThump() {
        guard GameState.shared.hapticsEnabled else { return }
        rigidGenerator.impactOccurred()
    }
    
    public func grazeFeedback() {
        guard GameState.shared.hapticsEnabled else { return }
        mediumGenerator.impactOccurred(intensity: 0.85)
    }
    
    public func hyperdriveTrigger() {
        guard GameState.shared.hapticsEnabled else { return }
        notifyGenerator.notificationOccurred(.success)
    }
    
    public func crashFeedback() {
        guard GameState.shared.hapticsEnabled else { return }
        heavyGenerator.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.notifyGenerator.notificationOccurred(.error)
        }
    }
    
    public func buttonClick() {
        guard GameState.shared.hapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }
}
