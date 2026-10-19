import SpriteKit
import SwiftUI

public class GameScene: SKScene, SKPhysicsContactDelegate {
    private var player: PlayerNode!
    private var starfield: SKEmitterNode?
    private var gridLines: [SKShapeNode] = []
    private var synthSun: SKShapeNode!
    private var horizonGlow: SKShapeNode!
    
    private var lastUpdateTime: TimeInterval = 0
    private var spawnTimer: TimeInterval = 0
    private var powerUpTimer: TimeInterval = 0
    private var currentScrollSpeed: CGFloat = 380.0
    private var targetPlayerX: CGFloat = 0.0
    private var isTouching: Bool = false
    
    private var lastTapTime: TimeInterval = 0
    private var gameCamera: SKCameraNode!
    
    override public func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.03, green: 0.02, blue: 0.08, alpha: 1.0)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setupCamera()
        setupSynthwaveHorizon()
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
    
    private func setupSynthwaveHorizon() {
        // Horizon Glow Line
        let hLine = SKShapeNode(rectOf: CGSize(width: size.width * 1.5, height: 4))
        hLine.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        hLine.fillColor = UIColor.cyan
        hLine.strokeColor = .white
        hLine.glowWidth = 10.0
        hLine.zPosition = -12
        addChild(hLine)
        self.horizonGlow = hLine
        
        // Synthwave Sun on the Horizon
        let sunRadius: CGFloat = 70.0
        synthSun = SKShapeNode(circleOfRadius: sunRadius)
        synthSun.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        synthSun.fillColor = UIColor(red: 1.0, green: 0.1, blue: 0.5, alpha: 0.85)
        synthSun.strokeColor = UIColor.yellow
        synthSun.lineWidth = 2.0
        synthSun.glowWidth = 14.0
        synthSun.zPosition = -13
        addChild(synthSun)
        
        // Horizontal stripes on the sun (Retro 80s aesthetic)
        for i in 1...5 {
            let yOffset = -CGFloat(i) * 11.0
            let stripe = SKShapeNode(rectOf: CGSize(width: sunRadius * 1.8, height: 3.5))
            stripe.position = CGPoint(x: 0, y: yOffset)
            stripe.fillColor = UIColor(red: 0.03, green: 0.02, blue: 0.08, alpha: 1.0)
            stripe.strokeColor = .clear
            synthSun.addChild(stripe)
        }
        
        let sunPulse = SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 1.0),
            SKAction.scale(to: 0.96, duration: 1.0)
        ])
        synthSun.run(SKAction.repeatForever(sunPulse))
    }
    
    private func setupBackgroundGrid() {
        // Perspective vertical highway grid lines
        let columns = 8
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
        for i in 0..<12 {
            let y = CGFloat(i) * (size.height / 10)
            let hLine = SKShapeNode(rectOf: CGSize(width: size.width, height: 2.0))
            hLine.position = CGPoint(x: size.width / 2, y: y)
            hLine.fillColor = UIColor.systemPink.withAlphaComponent(0.15)
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
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        player.zPosition = 10
        addChild(player)
    }
    
    public func startSession() {
        // Clear all dynamic obstacles & pickups
        for child in children {
            if child is ObstacleNode || child is CollectibleNode || child is PowerUpNode {
                child.removeFromParent()
            }
        }
        
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        targetPlayerX = size.width / 2
        player.alpha = 1.0
        player.setHyperdrive(active: false)
        
        currentScrollSpeed = 380.0
        GameState.shared.startNewGame()
        player.updatePowerUpVisuals()
        updateZoneColors()
    }
    
    private func updateZoneColors() {
        var sunColor = UIColor.systemPink
        var sunStroke = UIColor.yellow
        var glow = UIColor.cyan
        
        switch GameState.shared.currentZone {
        case 1: // Cyber Horizon
            sunColor = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8)
            sunStroke = UIColor.white
            glow = UIColor.cyan
        case 2: // Synthwave Sunset
            sunColor = UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 0.85)
            sunStroke = UIColor.yellow
            glow = UIColor.magenta
        case 3: // Matrix Mainframe
            sunColor = UIColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 0.85)
            sunStroke = UIColor.green
            glow = UIColor.systemGreen
        case 4: // Solar Inferno
            sunColor = UIColor(red: 1.0, green: 0.35, blue: 0.0, alpha: 0.9)
            sunStroke = UIColor.orange
            glow = UIColor.systemOrange
        case 5: // Quantum Singularity
            sunColor = UIColor.white
            sunStroke = UIColor.cyan
            glow = UIColor.white
        default:
            break
        }
        
        synthSun.fillColor = sunColor
        synthSun.strokeColor = sunStroke
        horizonGlow.fillColor = glow
    }
    
    // MARK: - Touch & Double Tap EMP
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard GameState.shared.phase == .playing, let touch = touches.first else { return }
        isTouching = true
        let now = CACurrentMediaTime()
        let loc = touch.location(in: self)
        
        // Double Tap check (EMP Shockwave Bomb)
        if now - lastTapTime < 0.28 {
            triggerEMPShockwave()
            lastTapTime = 0
        } else {
            lastTapTime = now
            targetPlayerX = max(player.radius + 10, min(size.width - player.radius - 10, loc.x))
            SoundEngine.shared.playDash()
            HapticManager.shared.lightTap()
        }
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
    
    // MARK: - EMP Shockwave Detonation
    private func triggerEMPShockwave() {
        guard GameState.shared.bombsAvailable > 0 else {
            GameState.shared.triggerComboBanner("BOMBES ÉPUISÉES!")
            HapticManager.shared.buttonClick()
            return
        }
        
        GameState.shared.bombsAvailable -= 1
        SoundEngine.shared.playBombExplosion()
        HapticManager.shared.heavyThud()
        triggerScreenShake(intensity: 14.0)
        
        // Visual shockwave ring expanding
        let shockwave = SKShapeNode(circleOfRadius: 10.0)
        shockwave.position = player.position
        shockwave.strokeColor = .white
        shockwave.fillColor = UIColor.cyan.withAlphaComponent(0.3)
        shockwave.lineWidth = 6.0
        shockwave.glowWidth = 12.0
        shockwave.zPosition = 40
        addChild(shockwave)
        
        shockwave.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 45.0, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Vaporize all obstacles currently on screen
        var destroyedCount = 0
        for child in children {
            if let obstacle = child as? ObstacleNode, !obstacle.isDestroyed {
                obstacle.smashInHyperdrive()
                destroyedCount += 1
            }
        }
        
        GameState.shared.addScore(destroyedCount * 100)
        GameState.shared.triggerComboBanner("⚡ EMP PURGE! (\(destroyedCount)) ⚡")
    }
    
    // MARK: - Update Loop
    override public func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard GameState.shared.phase == .playing else { return }
        
        // Chrono Warp Time Slow
        var effectiveSpeedMultiplier: CGFloat = 1.0
        if GameState.shared.chronoTimer > 0 {
            GameState.shared.chronoTimer -= dt
            effectiveSpeedMultiplier = 0.55 // Slow motion!
        }
        
        // Progressive speed curve
        let baseSpeed = 380.0 + CGFloat(GameState.shared.score) * 0.14
        currentScrollSpeed = min(800.0, baseSpeed) * effectiveSpeedMultiplier
        
        // Magnet timer
        if GameState.shared.magnetTimer > 0 {
            GameState.shared.magnetTimer -= dt
        }
        
        // Smooth player spring motion
        let diffX = targetPlayerX - player.position.x
        let vx = diffX * 13.0
        player.position.x += vx * CGFloat(dt)
        player.applyBankTilt(velocity: vx)
        player.updatePowerUpVisuals()
        
        // Parallax horizontal grid lines
        for line in gridLines {
            line.position.y -= currentScrollSpeed * CGFloat(dt)
            if line.position.y < 0 {
                line.position.y += size.height * 1.2
            }
        }
        
        // Hyperdrive timer
        if GameState.shared.isHyperdrive {
            GameState.shared.hyperdriveTimeRemaining -= dt
            player.setHyperdrive(active: true)
            if GameState.shared.hyperdriveTimeRemaining <= 0 {
                GameState.shared.endHyperdrive()
                player.setHyperdrive(active: false)
            }
        }
        
        // Update Obstacles, Collectibles & Power-ups
        for child in children {
            if let obstacle = child as? ObstacleNode {
                obstacle.position.y -= currentScrollSpeed * CGFloat(dt)
                if obstacle.position.y < -80 {
                    obstacle.removeFromParent()
                    GameState.shared.addScore(12)
                }
            } else if let bit = child as? CollectibleNode {
                bit.position.y -= currentScrollSpeed * CGFloat(dt)
                
                // Magnet radius: normal (90), Hyperdrive (280), Magnet PowerUp (360), Void Skin (+50%)
                var magnetRadius: CGFloat = 90.0
                if GameState.shared.isHyperdrive { magnetRadius = 280.0 }
                if GameState.shared.magnetTimer > 0 { magnetRadius = 380.0 }
                if SkinManager.shared.currentSkin.id == "skin_void" { magnetRadius *= 1.5 }
                
                let dx = player.position.x - bit.position.x
                let dy = player.position.y - bit.position.y
                let dist = sqrt(dx*dx + dy*dy)
                if dist < magnetRadius {
                    bit.magnetizeTowards(target: player.position, speed: 460.0 * CGFloat(dt))
                }
                
                if bit.position.y < -40 {
                    bit.removeFromParent()
                }
            } else if let pup = child as? PowerUpNode {
                pup.position.y -= currentScrollSpeed * CGFloat(dt)
                if pup.position.y < -40 {
                    pup.removeFromParent()
                }
            }
        }
        
        // Spawning Obstacles & Clusters
        spawnTimer += dt
        let spawnInterval = max(0.60, 1.40 - Double(currentScrollSpeed) / 950.0)
        if spawnTimer >= spawnInterval {
            spawnTimer = 0
            spawnObstacleWave()
            if Bool.random() {
                spawnCollectibleCluster()
            }
        }
        
        // Spawning Power-Ups (every ~14 seconds)
        powerUpTimer += dt
        if powerUpTimer >= 14.0 {
            powerUpTimer = 0
            spawnPowerUp()
        }
        
        updateZoneColors()
    }
    
    // MARK: - Spawning Methods
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
        let clusterCount = Int.random(in: 2...5)
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
    
    private func spawnPowerUp() {
        let types: [PowerUpType] = [.shield, .magnet, .chrono, .bomb]
        let chosen = types.randomElement() ?? .shield
        let pup = PowerUpNode(type: chosen)
        pup.position = CGPoint(
            x: CGFloat.random(in: 50...(size.width - 50)),
            y: size.height + 50.0
        )
        pup.zPosition = 7
        addChild(pup)
    }
    
    // MARK: - Physics Contacts
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
        
        // 2. Power-Up Pickup
        if mask & PhysicsCategory.powerUp != 0 && mask & PhysicsCategory.player != 0 {
            let pupBody = (contact.bodyA.categoryBitMask == PhysicsCategory.powerUp) ? contact.bodyA : contact.bodyB
            if let pup = pupBody.node as? PowerUpNode {
                pup.collect(in: self)
                GameState.shared.activatePowerUp(pup.type)
                player.updatePowerUpVisuals()
            }
            return
        }
        
        // 3. Graze (Near-Miss)
        if mask & PhysicsCategory.grazeZone != 0 && mask & PhysicsCategory.player != 0 {
            let grazeBody = (contact.bodyA.categoryBitMask == PhysicsCategory.grazeZone) ? contact.bodyA : contact.bodyB
            if let obstacle = grazeBody.node?.parent as? ObstacleNode, !obstacle.hasBeenGrazed {
                obstacle.markGrazed()
                GameState.shared.registerGraze()
                SoundEngine.shared.playGraze()
                HapticManager.shared.grazeFeedback()
                triggerSlowMotion(duration: 0.12)
                ParticleManager.shared.createGrazeSpark(at: player.position, color: .yellow, in: self)
                spawnFloatingText("+GRAZE!", color: .yellow, at: player.position)
            }
            return
        }
        
        // 4. Obstacle Collision
        if mask & PhysicsCategory.obstacle != 0 && mask & PhysicsCategory.player != 0 {
            let obstacleBody = (contact.bodyA.categoryBitMask == PhysicsCategory.obstacle) ? contact.bodyA : contact.bodyB
            if let obstacle = obstacleBody.node as? ObstacleNode {
                if GameState.shared.isHyperdrive {
                    obstacle.smashInHyperdrive()
                    GameState.shared.addScore(150)
                    HapticManager.shared.heavyThud()
                    triggerScreenShake(intensity: 8.0)
                    spawnFloatingText("DESTROYED!", color: .systemPink, at: obstacle.position)
                } else if GameState.shared.hasShield {
                    // Shield saves the player!
                    GameState.shared.hasShield = false
                    player.shatterShield(in: self)
                    obstacle.smashInHyperdrive()
                    triggerScreenShake(intensity: 10.0)
                    spawnFloatingText("SHIELD BREAK!", color: .cyan, at: player.position)
                } else {
                    // Lethal crash
                    triggerGameOver()
                }
            }
        }
    }
    
    private func spawnFloatingText(_ text: String, color: UIColor, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Black")
        label.text = text
        label.fontSize = 18
        label.fontColor = color
        label.position = position
        label.zPosition = 60
        addChild(label)
        
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.5),
                SKAction.scale(to: 1.3, duration: 0.25)
            ]),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    private func triggerGameOver() {
        GameState.shared.endGame()
        SoundEngine.shared.playCrash()
        HapticManager.shared.crashFeedback()
        triggerScreenShake(intensity: 18.0)
        
        ParticleManager.shared.createExplosion(at: player.position, color: SkinManager.shared.currentSkin.coreColor, in: self)
        player.alpha = 0.0
        
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
