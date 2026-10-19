import SpriteKit
import UIKit

public class PlayerNode: SKNode {
    private var outerRing: SKShapeNode!
    private var innerCore: SKShapeNode!
    private var hyperdriveShield: SKShapeNode!
    private var phaseShieldNode: SKShapeNode!
    private var magnetAuraNode: SKShapeNode!
    private var trailEmitter: SKEmitterNode?
    
    public private(set) var radius: CGFloat = 20.0
    private var currentSkin: SkinItem
    
    public init(skin: SkinItem) {
        self.currentSkin = skin
        super.init()
        setupNodes()
        setupPhysics()
        startAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        // Outer Hexagon
        let hexPath = UIBezierPath()
        let sides = 6
        let hexRadius: CGFloat = 22.0
        for i in 0..<sides {
            let angle = CGFloat(i) * (2.0 * .pi / CGFloat(sides))
            let pt = CGPoint(x: hexRadius * cos(angle), y: hexRadius * sin(angle))
            if i == 0 {
                hexPath.move(to: pt)
            } else {
                hexPath.addLine(to: pt)
            }
        }
        hexPath.close()
        
        outerRing = SKShapeNode(path: hexPath.cgPath)
        outerRing.strokeColor = currentSkin.glowColor
        outerRing.lineWidth = 3.0
        outerRing.fillColor = currentSkin.glowColor.withAlphaComponent(0.18)
        outerRing.glowWidth = 5.0
        addChild(outerRing)
        
        // Inner Diamond Core
        let diamondPath = UIBezierPath()
        let dRadius: CGFloat = 13.0
        diamondPath.move(to: CGPoint(x: 0, y: dRadius))
        diamondPath.addLine(to: CGPoint(x: dRadius, y: 0))
        diamondPath.addLine(to: CGPoint(x: 0, y: -dRadius))
        diamondPath.addLine(to: CGPoint(x: -dRadius, y: 0))
        diamondPath.close()
        
        innerCore = SKShapeNode(path: diamondPath.cgPath)
        innerCore.fillColor = currentSkin.coreColor
        innerCore.strokeColor = .white
        innerCore.lineWidth = 2.0
        innerCore.glowWidth = 4.0
        addChild(innerCore)
        
        // Hyperdrive Aura Shield
        hyperdriveShield = SKShapeNode(circleOfRadius: 38.0)
        hyperdriveShield.strokeColor = .white
        hyperdriveShield.fillColor = UIColor.cyan.withAlphaComponent(0.2)
        hyperdriveShield.lineWidth = 4.0
        hyperdriveShield.glowWidth = 8.0
        hyperdriveShield.alpha = 0.0
        addChild(hyperdriveShield)
        
        // Phase Shield Visual
        let shieldPath = UIBezierPath()
        let sRadius: CGFloat = 32.0
        for i in 0..<6 {
            let angle = CGFloat(i) * (.pi / 3.0)
            let pt = CGPoint(x: sRadius * cos(angle), y: sRadius * sin(angle))
            if i == 0 { shieldPath.move(to: pt) } else { shieldPath.addLine(to: pt) }
        }
        shieldPath.close()
        phaseShieldNode = SKShapeNode(path: shieldPath.cgPath)
        phaseShieldNode.strokeColor = UIColor.cyan
        phaseShieldNode.fillColor = UIColor.cyan.withAlphaComponent(0.25)
        phaseShieldNode.lineWidth = 3.0
        phaseShieldNode.glowWidth = 6.0
        phaseShieldNode.alpha = 0.0
        addChild(phaseShieldNode)
        
        // Magnet Aura Visual
        magnetAuraNode = SKShapeNode(circleOfRadius: 44.0)
        magnetAuraNode.strokeColor = UIColor.systemPurple
        magnetAuraNode.lineWidth = 2.0
        magnetAuraNode.glowWidth = 5.0
        magnetAuraNode.alpha = 0.0
        addChild(magnetAuraNode)
        
        // Particle Trail
        updateTrail()
    }
    
    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 16.0)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.grazeZone | PhysicsCategory.collectible | PhysicsCategory.powerUp
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }
    
    private func startAnimations() {
        let rotateRight = SKAction.rotate(byAngle: -.pi * 2, duration: 3.5)
        outerRing.run(SKAction.repeatForever(rotateRight))
        
        let rotateLeft = SKAction.rotate(byAngle: .pi * 2, duration: 1.8)
        innerCore.run(SKAction.repeatForever(rotateLeft))
        
        let shieldPulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.4),
            SKAction.scale(to: 0.95, duration: 0.4)
        ])
        phaseShieldNode.run(SKAction.repeatForever(shieldPulse))
        
        let magnetSpin = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        magnetAuraNode.run(SKAction.repeatForever(magnetSpin))
    }
    
    public func updatePowerUpVisuals() {
        // Shield
        let showShield = GameState.shared.hasShield
        phaseShieldNode.alpha = showShield ? 1.0 : 0.0
        
        // Magnet
        let showMagnet = GameState.shared.magnetTimer > 0
        magnetAuraNode.alpha = showMagnet ? 0.8 : 0.0
    }
    
    public func shatterShield(in parent: SKNode) {
        phaseShieldNode.alpha = 0.0
        ParticleManager.shared.createExplosion(at: self.position, color: .cyan, in: parent)
        SoundEngine.shared.playShieldBreak()
        HapticManager.shared.heavyThud()
    }
    
    public func setHyperdrive(active: Bool) {
        if active {
            hyperdriveShield.removeAllActions()
            let pulse = SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.2, duration: 0.25),
                    SKAction.fadeAlpha(to: 0.9, duration: 0.25)
                ]),
                SKAction.group([
                    SKAction.scale(to: 0.95, duration: 0.25),
                    SKAction.fadeAlpha(to: 0.35, duration: 0.25)
                ])
            ])
            hyperdriveShield.run(SKAction.repeatForever(pulse))
        } else {
            hyperdriveShield.removeAllActions()
            hyperdriveShield.run(SKAction.fadeAlpha(to: 0.0, duration: 0.2))
        }
    }
    
    public func updateSkin(_ skin: SkinItem) {
        self.currentSkin = skin
        outerRing.strokeColor = skin.glowColor
        outerRing.fillColor = skin.glowColor.withAlphaComponent(0.18)
        innerCore.fillColor = skin.coreColor
        updateTrail()
    }
    
    private func updateTrail() {
        trailEmitter?.removeFromParent()
        let emitter = ParticleManager.shared.createPlayerTrail(color: currentSkin.trailColor)
        emitter.position = CGPoint(x: 0, y: -10)
        emitter.zPosition = -1
        addChild(emitter)
        self.trailEmitter = emitter
    }
    
    public func applyBankTilt(velocity: CGFloat) {
        let maxTilt: CGFloat = .pi / 7
        let targetAngle = -max(-maxTilt, min(maxTilt, velocity * 0.0035))
        let tiltAction = SKAction.rotate(toAngle: targetAngle, duration: 0.08, shortestUnitArc: true)
        self.run(tiltAction)
    }
}
