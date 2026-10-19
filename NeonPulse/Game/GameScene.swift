import SpriteKit
import SwiftUI

public class GameScene: SKScene, SKPhysicsContactDelegate {
    private var player: PlayerNode!
    private var starfield: SKEmitterNode?
    private var gridLines: [SKShapeNode] = []
    
    private var lastUpdateTime: TimeInterval = 0
    private var spawnTimer: TimeInterval = 0
    private var currentScrollSpeed: CGFloat = 380.0
    private var targetPlayerX: CGFloat = 0.0
    private var isTouching: Bool = false
    
    private var gameCamera: SKCameraNode!
    
    override public func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.04, green: 0.03, blue: 0.09, alpha: 1.0)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setupCamera()
        setupBackgroundGrid()
        setupStarfield()
        setupPlayer()
        
        targetPlayerX = size.width / 2
        startSession()
    }
    
    private func setupCamera() {
        gameCamera = SKCameraNode()
        gameCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.camera = gameCamera
        addChild(gameCamera)
    }
    
    private func setupBackgroundGrid() {
        // Vertical cyber highway grid lines
        let columns = 7
        let colWidth = size.width / CGFloat(columns)
        for i in 0...columns {
            let x = CGFloat(i) * colWidth
            let line = SKShapeNode(rectOf: CGSize(width: 1.5, height: size.height * 2))
            line.position = CGPoint(x: x, y: size.height / 2)
            line.fillColor = UIColor.cyan.withAlphaComponent(0.12)
            line.strokeColor = .clear
            line.zPosition = -10
            addChild(line)
        }
        
        // Horizontal scrolling grid pulses
        for i in 0..<10 {
            let y = CGFloat(i) * (size.height / 8)
            let hLine = SKShapeNode(rectOf: CGSize(width: size.width, height: 1.5))
            hLine.position = CGPoint(x: size.width / 2, y: y)
            hLine.fillColor = UIColor.magenta.withAlphaComponent(0.15)
            hLine.strokeColor = .clear
            hLine.zPosition = -9
            addChild(hLine)
            gridLines.append(hLine)
        }
    }
    
    private func setupStarfield() {
        let stars = ParticleManager.shared.createStarfield(size: size)
        addChild(stars)
        self.starfield = stars
    }
    
    private func setupPlayer() {
        let skin = SkinManager.shared.currentSkin
        player = PlayerNode(skin: skin)
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        player.zPosition = 10
        addChild(player)
    }
    
    public func startSession() {
        // Clear all obstacles & collectibles
        for child in children {
            if child is ObstacleNode || child is CollectibleNode {
                child.removeFromParent()
            }
        }
        
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        targetPlayerX = size.width / 2
        player.alpha = 1.0
        player.setHyperdrive(active: false)
        
        currentScrollSpeed = 380.0
        GameState.shared.startNewGame()
    }
    
    // MARK: - Touch Input
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard GameState.shared.phase == .playing, let touch = touches.first else { return }
        isTouching = true
        let loc = touch.location(in: self)
        targetPlayerX = max(player.radius + 10, min(size.width - player.radius - 10, loc.x))
        SoundEngine.shared.playDash()
        HapticManager.shared.lightTap()
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard GameState.shared.phase == .playing, let touch = touches.first else { return }
        let loc = touch.location(in: self)
        targetPlayerX = max(player.radius + 10, min(size.width - player.radius - 10, loc.x))
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
    
    // MARK: - Update Loop
    override public func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard GameState.shared.phase == .playing else { return }
        
        // Speed up progressively (max 750)
        currentScrollSpeed = min(750.0, 380.0 + CGFloat(GameState.shared.score) * 0.12)
        
        // Smooth player movement with spring physics
        let diffX = targetPlayerX - player.position.x
        let vx = diffX * 12.0
        player.position.x += vx * CGFloat(dt)
        player.applyBankTilt(velocity: vx)
        
        // Update horizontal grid lines scroll
        for line in gridLines {
            line.position.y -= currentScrollSpeed * CGFloat(dt)
            if line.position.y < 0 {
                line.position.y += size.height * 1.25
            }
        }
        
        // Update Hyperdrive status
        if GameState.shared.isHyperdrive {
            GameState.shared.hyperdriveTimeRemaining -= dt
            player.setHyperdrive(active: true)
            if GameState.shared.hyperdriveTimeRemaining <= 0 {
                GameState.shared.endHyperdrive()
                player.setHyperdrive(active: false)
            }
        }
        
        // Obstacle & Collectible movement & cleanup
        for child in children {
            if let obstacle = child as? ObstacleNode {
                obstacle.position.y -= currentScrollSpeed * CGFloat(dt)
                if obstacle.position.y < -80 {
                    obstacle.removeFromParent()
                    GameState.shared.addScore(10)
                }
            } else if let bit = child as? CollectibleNode {
                bit.position.y -= currentScrollSpeed * CGFloat(dt)
                
                // Magnetic pull when player is close or in Hyperdrive
                let dx = player.position.x - bit.position.x
                let dy = player.position.y - bit.position.y
                let dist = sqrt(dx*dx + dy*dy)
                let magnetRadius: CGFloat = GameState.shared.isHyperdrive ? 260.0 : 90.0
                if dist < magnetRadius {
                    bit.magnetizeTowards(target: player.position, speed: 400.0 * CGFloat(dt))
                }
                
                if bit.position.y < -40 {
                    bit.removeFromParent()
                }
            }
        }
        
        // Spawning Logic
        spawnTimer += dt
        let spawnInterval = max(0.65, 1.45 - Double(currentScrollSpeed) / 1000.0)
        if spawnTimer >= spawnInterval {
            spawnTimer = 0
            spawnObstacleWave()
            if Bool.random() {
                spawnCollectibleCluster()
            }
        }
    }
    
    // MARK: - Spawning
    private func spawnObstacleWave() {
        let types: [ObstacleType] = [.laserBar, .spikeMine, .phaseGate]
        let chosenType = types.randomElement() ?? .spikeMine
        let obstacle = ObstacleNode(type: chosenType, screenWidth: size.width)
        
        let minX = player.radius + 30.0
        let maxX = size.width - player.radius - 30.0
        obstacle.position = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: size.height + 60.0
        )
        obstacle.zPosition = 5
        addChild(obstacle)
    }
    
    private func spawnCollectibleCluster() {
        let clusterCount = Int.random(in: 2...4)
        let startX = CGFloat.random(in: 40...(size.width - 40))
        for i in 0..<clusterCount {
            let bit = CollectibleNode()
            bit.position = CGPoint(
                x: startX,
                y: size.height + 50.0 + CGFloat(i * 35)
            )
            bit.zPosition = 6
            addChild(bit)
        }
    }
    
    // MARK: - Physics & Collisions
    public func didBegin(_ contact: SKPhysicsContact) {
        guard GameState.shared.phase == .playing else { return }
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // 1. Collectible Pickup
        if mask & PhysicsCategory.collectible != 0 && mask & PhysicsCategory.player != 0 {
            let collectibleBody = (contact.bodyA.categoryBitMask == PhysicsCategory.collectible) ? contact.bodyA : contact.bodyB
            if let bit = collectibleBody.node as? CollectibleNode {
                bit.collect(in: self)
                GameState.shared.collectBit()
                SoundEngine.shared.playCollectBit(combo: GameState.shared.combo)
                HapticManager.shared.lightTap()
            }
            return
        }
        
        // 2. Graze (Near-Miss)
        if mask & PhysicsCategory.grazeZone != 0 && mask & PhysicsCategory.player != 0 {
            let grazeBody = (contact.bodyA.categoryBitMask == PhysicsCategory.grazeZone) ? contact.bodyA : contact.bodyB
            if let obstacle = grazeBody.node?.parent as? ObstacleNode, !obstacle.hasBeenGrazed {
                obstacle.markGrazed()
                GameState.shared.registerGraze()
                SoundEngine.shared.playGraze()
                HapticManager.shared.grazeFeedback()
                triggerSlowMotion(duration: 0.12)
                ParticleManager.shared.createGrazeSpark(at: player.position, color: .yellow, in: self)
            }
            return
        }
        
        // 3. Obstacle Collision
        if mask & PhysicsCategory.obstacle != 0 && mask & PhysicsCategory.player != 0 {
            let obstacleBody = (contact.bodyA.categoryBitMask == PhysicsCategory.obstacle) ? contact.bodyA : contact.bodyB
            if let obstacle = obstacleBody.node as? ObstacleNode {
                if GameState.shared.isHyperdrive {
                    // Invincible smash!
                    obstacle.smashInHyperdrive()
                    GameState.shared.addScore(150)
                    HapticManager.shared.heavyThud()
                    triggerScreenShake(intensity: 8.0)
                } else {
                    // Lethal crash!
                    triggerGameOver()
                }
            }
        }
    }
    
    private func triggerGameOver() {
        GameState.shared.endGame()
        SoundEngine.shared.playCrash()
        HapticManager.shared.crashFeedback()
        triggerScreenShake(intensity: 18.0)
        
        // Explode player into neon fragments
        ParticleManager.shared.createExplosion(at: player.position, color: SkinManager.shared.currentSkin.coreColor, in: self)
        player.alpha = 0.0
        
        // Record mission stats
        ScoreManager.shared.recordRunStats(
            grazes: GameState.shared.grazesThisRun,
            maxCombo: GameState.shared.combo,
            bits: GameState.shared.bitsCollectedThisRun,
            hyperCount: GameState.shared.isHyperdrive ? 1 : 0
        )
    }
    
    private func triggerScreenShake(intensity: CGFloat) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -intensity, y: intensity, duration: 0.04),
            SKAction.moveBy(x: intensity * 1.5, y: -intensity * 1.2, duration: 0.04),
            SKAction.moveBy(x: -intensity * 0.8, y: intensity * 0.6, duration: 0.04),
            SKAction.moveTo(x: size.width / 2, duration: 0.04)
        ])
        gameCamera.run(shake)
    }
    
    private func triggerSlowMotion(duration: Double) {
        physicsWorld.speed = 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.physicsWorld.speed = 1.0
        }
    }
}
