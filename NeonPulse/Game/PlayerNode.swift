import SpriteKit
import UIKit

public class PlayerNode: SKNode {
    private var outerRing: SKShapeNode!
    private var innerCore: SKShapeNode!
    private var hyperdriveShield: SKShapeNode!
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
        outerRing.fillColor = currentSkin.glowColor.withAlphaComponent(0.15)
        outerRing.glowWidth = 4.0
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
        innerCore.lineWidth = 1.5
        innerCore.glowWidth = 3.0
        addChild(innerCore)
        
        // Hyperdrive Aura Shield (Hidden by default)
        hyperdriveShield = SKShapeNode(circleOfRadius: 36.0)
        hyperdriveShield.strokeColor = .white
        hyperdriveShield.fillColor = UIColor.cyan.withAlphaComponent(0.2)
        hyperdriveShield.lineWidth = 4.0
        hyperdriveShield.glowWidth = 8.0
        hyperdriveShield.alpha = 0.0
        addChild(hyperdriveShield)
        
        // Particle Trail
        updateTrail()
    }
    
    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 16.0)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.grazeZone | PhysicsCategory.collectible
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }
    
    private func startAnimations() {
        // Rotate outer ring continuously
        let rotateRight = SKAction.rotate(byAngle: -.pi * 2, duration: 4.0)
        outerRing.run(SKAction.repeatForever(rotateRight))
        
        // Rotate inner core opposite direction
        let rotateLeft = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        innerCore.run(SKAction.repeatForever(rotateLeft))
    }
    
    public func setHyperdrive(active: Bool) {
        if active {
            hyperdriveShield.removeAllActions()
            let pulse = SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.15, duration: 0.25),
                    SKAction.fadeAlpha(to: 0.8, duration: 0.25)
                ]),
                SKAction.group([
                    SKAction.scale(to: 0.95, duration: 0.25),
                    SKAction.fadeAlpha(to: 0.3, duration: 0.25)
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
        outerRing.fillColor = skin.glowColor.withAlphaComponent(0.15)
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
        let maxTilt: CGFloat = .pi / 8
        let targetAngle = -max(-maxTilt, min(maxTilt, velocity * 0.003))
        let tiltAction = SKAction.rotate(toAngle: targetAngle, duration: 0.1, shortestUnitArc: true)
        self.run(tiltAction)
    }
}
