import SpriteKit
import UIKit

public class ParticleManager {
    public static let shared = ParticleManager()
    
    private lazy var sparkTexture: SKTexture = {
        let size: CGFloat = 12.0
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 2, y: 2, width: 8, height: 8))
        }
        return SKTexture(image: img)
    }()
    
    private lazy var diamondTexture: SKTexture = {
        let size: CGFloat = 16.0
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { ctx in
            UIColor.white.setFill()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 8, y: 0))
            path.addLine(to: CGPoint(x: 16, y: 8))
            path.addLine(to: CGPoint(x: 8, y: 16))
            path.addLine(to: CGPoint(x: 0, y: 8))
            path.close()
            path.fill()
        }
        return SKTexture(image: img)
    }()
    
    private init() {}
    
    public func createPlayerTrail(color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = sparkTexture
        emitter.particleBirthRate = 45
        emitter.particleLifetime = 0.35
        emitter.particleLifetimeRange = 0.1
        emitter.particlePositionRange = CGVector(dx: 10, dy: 6)
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 6
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -2.2
        emitter.particleScale = 0.8
        emitter.particleScaleSpeed = -1.2
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        return emitter
    }
    
    public func createGrazeSpark(at position: CGPoint, color: UIColor, in parent: SKNode) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = sparkTexture
        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 25
        emitter.particleLifetime = 0.4
        emitter.particleLifetimeRange = 0.15
        emitter.particleSpeed = 160
        emitter.particleSpeedRange = 80
        emitter.emissionAngleRange = 2 * .pi
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -2.5
        emitter.particleScale = 0.9
        emitter.particleScaleSpeed = -1.5
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.position = position
        emitter.zPosition = 50
        
        parent.addChild(emitter)
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.removeFromParent()
        ]))
    }
    
    public func createBitCollectBurst(at position: CGPoint, color: UIColor, in parent: SKNode) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = diamondTexture
        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 18
        emitter.particleLifetime = 0.45
        emitter.particleSpeed = 140
        emitter.particleSpeedRange = 60
        emitter.emissionAngleRange = 2 * .pi
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -2.0
        emitter.particleScale = 0.7
        emitter.particleScaleSpeed = -1.0
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.position = position
        emitter.zPosition = 50
        
        parent.addChild(emitter)
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.removeFromParent()
        ]))
    }
    
    public func createExplosion(at position: CGPoint, color: UIColor, in parent: SKNode) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = diamondTexture
        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 60
        emitter.particleLifetime = 0.7
        emitter.particleLifetimeRange = 0.3
        emitter.particleSpeed = 240
        emitter.particleSpeedRange = 120
        emitter.emissionAngleRange = 2 * .pi
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.4
        emitter.particleScale = 1.2
        emitter.particleScaleSpeed = -1.3
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.position = position
        emitter.zPosition = 60
        
        parent.addChild(emitter)
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    public func createStarfield(size: CGSize) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = sparkTexture
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 3.0
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.particleSpeed = 260
        emitter.particleSpeedRange = 100
        emitter.emissionAngle = -.pi / 2
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.4
        emitter.particleScale = 0.35
        emitter.particleScaleRange = 0.25
        emitter.particleColor = UIColor(white: 0.8, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 20)
        emitter.zPosition = -5
        emitter.advanceSimulationTime(3.0)
        return emitter
    }
}
