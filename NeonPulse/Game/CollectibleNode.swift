import SpriteKit
import UIKit

public class CollectibleNode: SKNode {
    private var diamond: SKShapeNode!
    public private(set) var isCollected: Bool = false
    
    override init() {
        super.init()
        setupShape()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShape() {
        let path = UIBezierPath()
        let radius: CGFloat = 10.0
        path.move(to: CGPoint(x: 0, y: radius))
        path.addLine(to: CGPoint(x: radius * 0.7, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -radius))
        path.addLine(to: CGPoint(x: -radius * 0.7, y: 0))
        path.close()
        
        diamond = SKShapeNode(path: path.cgPath)
        diamond.fillColor = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 0.9)
        diamond.strokeColor = .white
        diamond.lineWidth = 1.5
        diamond.glowWidth = 4.0
        addChild(diamond)
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 1.8)
        diamond.run(SKAction.repeatForever(rotate))
        
        let floatAction = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.35),
            SKAction.scale(to: 0.9, duration: 0.35)
        ])
        diamond.run(SKAction.repeatForever(floatAction))
    }
    
    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 14.0)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.collectible
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }
    
    public func collect(in parent: SKNode) {
        guard !isCollected else { return }
        isCollected = true
        self.physicsBody = nil
        
        ParticleManager.shared.createBitCollectBurst(at: self.position, color: .cyan, in: parent)
        
        self.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.8, duration: 0.12),
                SKAction.fadeOut(withDuration: 0.12)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    public func magnetizeTowards(target: CGPoint, speed: CGFloat) {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let dist = sqrt(dx*dx + dy*dy)
        if dist > 0 {
            let vx = (dx / dist) * speed
            let vy = (dy / dist) * speed
            position.x += vx
            position.y += vy
        }
    }
}
