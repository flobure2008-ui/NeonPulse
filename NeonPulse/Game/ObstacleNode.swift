import SpriteKit
import UIKit

public enum ObstacleType: CaseIterable {
    case laserBar
    case spikeMine
    case phaseGate
}

public class ObstacleNode: SKNode {
    public let type: ObstacleType
    public private(set) var hasBeenGrazed: Bool = false
    public private(set) var isDestroyed: Bool = false
    
    private var mainShape: SKShapeNode!
    private var grazeZoneNode: SKNode!
    
    public init(type: ObstacleType, screenWidth: CGFloat) {
        self.type = type
        super.init()
        buildObstacle(screenWidth: screenWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildObstacle(screenWidth: CGFloat) {
        switch type {
        case .laserBar:
            buildLaserBar(screenWidth: screenWidth)
        case .spikeMine:
            buildSpikeMine()
        case .phaseGate:
            buildPhaseGate(screenWidth: screenWidth)
        }
    }
    
    private func buildLaserBar(screenWidth: CGFloat) {
        // Laser bar with gap for player
        let barWidth: CGFloat = CGFloat.random(in: 100...150)
        let barHeight: CGFloat = 20.0
        
        mainShape = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4.0)
        mainShape.fillColor = UIColor.systemRed.withAlphaComponent(0.85)
        mainShape.strokeColor = UIColor.white
        mainShape.lineWidth = 2.0
        mainShape.glowWidth = 4.0
        addChild(mainShape)
        
        // Lethal physics body
        let body = SKPhysicsBody(rectangleOf: CGSize(width: barWidth, height: barHeight))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
        
        // Graze Zone (wider boundary around the bar)
        let grazeBody = SKPhysicsBody(rectangleOf: CGSize(width: barWidth + 36.0, height: barHeight + 36.0))
        grazeBody.isDynamic = false
        grazeBody.categoryBitMask = PhysicsCategory.grazeZone
        grazeBody.contactTestBitMask = PhysicsCategory.player
        grazeBody.collisionBitMask = PhysicsCategory.none
        
        grazeZoneNode = SKNode()
        grazeZoneNode.physicsBody = grazeBody
        addChild(grazeZoneNode)
    }
    
    private func buildSpikeMine() {
        let radius: CGFloat = 22.0
        let path = UIBezierPath()
        let points = 8
        for i in 0..<points * 2 {
            let r: CGFloat = (i % 2 == 0) ? radius : (radius * 0.55)
            let angle = CGFloat(i) * (.pi / CGFloat(points))
            let pt = CGPoint(x: r * cos(angle), y: r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.close()
        
        mainShape = SKShapeNode(path: path.cgPath)
        mainShape.fillColor = UIColor(red: 1.0, green: 0.1, blue: 0.35, alpha: 0.9)
        mainShape.strokeColor = .white
        mainShape.lineWidth = 2.0
        mainShape.glowWidth = 5.0
        addChild(mainShape)
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.5)
        mainShape.run(SKAction.repeatForever(rotate))
        
        // Lethal physics body
        let body = SKPhysicsBody(circleOfRadius: radius * 0.8)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
        
        // Graze Zone
        let grazeBody = SKPhysicsBody(circleOfRadius: radius + 24.0)
        grazeBody.isDynamic = false
        grazeBody.categoryBitMask = PhysicsCategory.grazeZone
        grazeBody.contactTestBitMask = PhysicsCategory.player
        grazeBody.collisionBitMask = PhysicsCategory.none
        
        grazeZoneNode = SKNode()
        grazeZoneNode.physicsBody = grazeBody
        addChild(grazeZoneNode)
    }
    
    private func buildPhaseGate(screenWidth: CGFloat) {
        let pillarWidth: CGFloat = 16.0
        let pillarHeight: CGFloat = 40.0
        let gap: CGFloat = 90.0
        
        // Left pillar
        let leftPillar = SKShapeNode(rectOf: CGSize(width: pillarWidth, height: pillarHeight), cornerRadius: 3.0)
        leftPillar.position = CGPoint(x: -gap / 2, y: 0)
        leftPillar.fillColor = UIColor.purple
        leftPillar.strokeColor = UIColor.cyan
        leftPillar.lineWidth = 2.0
        addChild(leftPillar)
        
        // Right pillar
        let rightPillar = SKShapeNode(rectOf: CGSize(width: pillarWidth, height: pillarHeight), cornerRadius: 3.0)
        rightPillar.position = CGPoint(x: gap / 2, y: 0)
        rightPillar.fillColor = UIColor.purple
        rightPillar.strokeColor = UIColor.cyan
        rightPillar.lineWidth = 2.0
        addChild(rightPillar)
        
        // Energy beam connecting them
        let beam = SKShapeNode(rectOf: CGSize(width: gap, height: 4.0))
        beam.fillColor = UIColor.cyan
        beam.strokeColor = UIColor.white
        beam.glowWidth = 6.0
        addChild(beam)
        
        mainShape = beam
        
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.4),
            SKAction.fadeAlpha(to: 1.0, duration: 0.4)
        ])
        beam.run(SKAction.repeatForever(pulse))
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: gap + pillarWidth * 2, height: 12.0))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
        
        let grazeBody = SKPhysicsBody(rectangleOf: CGSize(width: gap + pillarWidth * 2 + 30.0, height: 40.0))
        grazeBody.isDynamic = false
        grazeBody.categoryBitMask = PhysicsCategory.grazeZone
        grazeBody.contactTestBitMask = PhysicsCategory.player
        grazeBody.collisionBitMask = PhysicsCategory.none
        
        grazeZoneNode = SKNode()
        grazeZoneNode.physicsBody = grazeBody
        addChild(grazeZoneNode)
    }
    
    public func markGrazed() {
        hasBeenGrazed = true
        grazeZoneNode.physicsBody = nil
    }
    
    public func smashInHyperdrive() {
        guard !isDestroyed else { return }
        isDestroyed = true
        self.physicsBody = nil
        grazeZoneNode.physicsBody = nil
        
        if let parent = self.parent {
            ParticleManager.shared.createExplosion(at: self.position, color: .systemPink, in: parent)
        }
        
        self.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.4, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.1)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
