import SpriteKit
import UIKit

public enum PowerUpType: CaseIterable {
    case shield
    case magnet
    case chrono
    case bomb
    
    public var title: String {
        switch self {
        case .shield: return "BOUCLIER"
        case .magnet: return "AIMANT"
        case .chrono: return "CHRONO"
        case .bomb: return "BOMBE EMP"
        }
    }
    
    public var glowColor: UIColor {
        switch self {
        case .shield: return UIColor.cyan
        case .magnet: return UIColor.systemPurple
        case .chrono: return UIColor.systemOrange
        case .bomb: return UIColor.systemYellow
        }
    }
}

public class PowerUpNode: SKNode {
    public let type: PowerUpType
    public private(set) var isCollected: Bool = false
    private var iconShape: SKShapeNode!
    
    public init(type: PowerUpType) {
        self.type = type
        super.init()
        setupVisuals()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVisuals() {
        // Outer pulsing ring
        let outer = SKShapeNode(circleOfRadius: 22.0)
        outer.strokeColor = type.glowColor
        outer.lineWidth = 2.5
        outer.fillColor = type.glowColor.withAlphaComponent(0.2)
        outer.glowWidth = 6.0
        addChild(outer)
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.35),
            SKAction.scale(to: 0.92, duration: 0.35)
        ])
        outer.run(SKAction.repeatForever(pulse))
        
        // Inner glyph
        let glyph = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        switch type {
        case .shield: glyph.text = "🛡"
        case .magnet: glyph.text = "🧲"
        case .chrono: glyph.text = "⏱"
        case .bomb: glyph.text = "⚡"
        }
        glyph.fontSize = 20
        glyph.verticalAlignmentMode = .center
        glyph.horizontalAlignmentMode = .center
        glyph.position = .zero
        addChild(glyph)
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        outer.run(SKAction.repeatForever(rotate))
    }
    
    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 22.0)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.powerUp
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }
    
    public func collect(in parent: SKNode) {
        guard !isCollected else { return }
        isCollected = true
        self.physicsBody = nil
        
        ParticleManager.shared.createBitCollectBurst(at: self.position, color: type.glowColor, in: parent)
        
        self.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
