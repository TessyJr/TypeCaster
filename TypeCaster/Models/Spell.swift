import SpriteKit

class Spell {
    var hudSpriteNode: SKSpriteNode
    var chant: String
    var cooldownDuration: CGFloat
    var isInCooldown: Bool = false
    var speed: CGFloat
    var textures: [SKTexture]
    
    init(hudSpriteNode: SKSpriteNode, chant: String, cooldownDuration: CGFloat, speed: CGFloat, textures: [SKTexture]) {
        self.hudSpriteNode = hudSpriteNode
        self.chant = chant
        self.cooldownDuration = cooldownDuration
        self.speed = speed
        self.textures = textures
    }
    
    func summonSpellInExplorationScene(scene: ExplorationSceneProtocol) {
        let travelDistance: CGFloat = 64.0
        let travelSpeed: CGFloat = 0.5
        
        isInCooldown = true
        hudSpriteNode.alpha = 0.2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownDuration) {
            self.isInCooldown = false
            self.hudSpriteNode.alpha = 1
        }
        
        let spellNode: SKSpriteNode = SKSpriteNode()
        spellNode.size = CGSize(width: 32.0, height: 32.0)
        spellNode.position = scene.player.spriteNode.position
        
        let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(moveAnimation)
        spellNode.run(repeatAnimation)
        
        scene.spellNode = spellNode
        scene.addChild(spellNode)
        
        let moveAction: SKAction
        switch scene.player.direction {
        case .left:
            spellNode.xScale = -1
            moveAction = SKAction.moveBy(x: -travelDistance, y: 0, duration: travelSpeed)
            
        case .right:
            moveAction = SKAction.moveBy(x: travelDistance, y: 0, duration: travelSpeed)
            
        case .up:
            spellNode.zRotation = .pi / 2
            moveAction = SKAction.moveBy(x: 0, y: travelDistance, duration: travelSpeed)
            
        case .down:
            spellNode.zRotation = -.pi / 2
            moveAction = SKAction.moveBy(x: 0, y: -travelDistance, duration: travelSpeed)
        }
        
        let roundPositionAction = SKAction.run {
            spellNode.position.x = round(spellNode.position.x)
            spellNode.position.y = round(spellNode.position.y)
        }
        
        let removeAction = SKAction.run {
            spellNode.removeFromParent()
            scene.spellNode = nil
        }
        
        let sequence = SKAction.sequence([moveAction, roundPositionAction, removeAction])
        
        spellNode.run(sequence)
    }
}

class Rock: Spell {
    init() {
        let hudSpriteNode = SKSpriteNode(imageNamed: "hud-rock")
        let chant = ""
        let cooldownDuration: CGFloat = 2.0
        let speed: CGFloat = 1.0
        let textures = [
            SKTexture(imageNamed: "rock")
        ]
        
        super.init(hudSpriteNode: hudSpriteNode, chant: chant, cooldownDuration: cooldownDuration, speed: speed, textures: textures)
    }
}

class Fireball: Spell {
    init() {
        let hudSpriteNode = SKSpriteNode(imageNamed: "hud-fireball")
        let chant = "fireball"
        let cooldownDuration: CGFloat = 3.0
        let speed: CGFloat = 1.0
        let textures = [
            SKTexture(imageNamed: "fireball-1"),
            SKTexture(imageNamed: "fireball-2"),
            SKTexture(imageNamed: "fireball-3"),
            SKTexture(imageNamed: "fireball-4")
        ]
        
        super.init(hudSpriteNode: hudSpriteNode, chant: chant, cooldownDuration: cooldownDuration, speed: speed, textures: textures)
    }
}

class Iceblast: Spell {
    init() {
        let hudSpriteNode = SKSpriteNode(imageNamed: "hud-iceblast")
        let chant = "ice blast"
        let cooldownDuration: CGFloat = 5.0
        let speed: CGFloat = 1.0
        let textures = [
            SKTexture(imageNamed: "iceblast-1"),
            SKTexture(imageNamed: "iceblast-2"),
            SKTexture(imageNamed: "iceblast-3")
        ]
        
        super.init(hudSpriteNode: hudSpriteNode, chant: chant, cooldownDuration: cooldownDuration, speed: speed, textures: textures)
    }
}
