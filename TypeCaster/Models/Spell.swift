import SpriteKit

class Spell {
    var chant: String
    var cooldownDuration: CGFloat
    var isInCooldown: Bool = false
    var speed: CGFloat
    var cooldownTexture: SKTexture
    var textures: [SKTexture]
    var damage: Int
    var spellType: SpellSfxType
    
    init(chant: String, cooldownDuration: CGFloat, speed: CGFloat, cooldownTexture: SKTexture, textures: [SKTexture], damage: Int, spellType: SpellSfxType) {
        self.chant = chant
        self.cooldownDuration = cooldownDuration
        self.speed = speed
        self.cooldownTexture = cooldownTexture
        self.textures = textures
        self.damage = damage
        self.spellType = spellType
    }
    
    func summonSpellInExplorationScene(scene: ExplorationSceneProtocol) {
        let travelDistance: CGFloat = 64.0
        let travelSpeed: CGFloat = 0.5
        
        isInCooldown = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownDuration) {
            self.isInCooldown = false
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
        
        AudioManager.shared.playSpellSfx(node: spellNode, spellType: self.spellType)
        spellNode.run(sequence)
    }
    
    func summonSpellInBattleScene(scene: BattleSceneProtocol, enemy: Enemy) {
        isInCooldown = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownDuration) {
            self.isInCooldown = false
        }
        
        let spellNode: SKSpriteNode = SKSpriteNode()
        spellNode.name = "spell"
        spellNode.size = CGSize(width: 32.0, height: 32.0)
        spellNode.position = scene.player.spriteNode.position
        
        let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(moveAnimation)
        spellNode.run(repeatAnimation)
        
        scene.spellNode = spellNode
        scene.addChild(spellNode)
        
        let dx = enemy.spriteNode.position.x - spellNode.position.x
        let dy = enemy.spriteNode.position.y - spellNode.position.y
        let angle = atan2(dy, dx)
        spellNode.zRotation = angle
        
        let moveAction = SKAction.move(to: enemy.spriteNode.position, duration: 1.0)
        
        let removeAction = SKAction.removeFromParent()
        
        let damageAction = SKAction.run {
            enemy.getHurt(scene: scene, damage: self.damage)
        }
        
        let sequence = SKAction.sequence([moveAction, removeAction, damageAction])
        
        AudioManager.shared.playSpellSfx(node: spellNode, spellType: self.spellType)
        
        spellNode.run(sequence)
    }
    
    func summonShield(player: Player) {}
}

class Rock: Spell {
    init() {
        let chant = ""
        let cooldownDuration: CGFloat = 1.0
        let speed: CGFloat = 1.0
        let cooldownTexture = SKTexture(imageNamed: "cooldown-rock")
        let textures = [
            SKTexture(imageNamed: "rock")
        ]
        let damage = 1
        let spellType: SpellSfxType = .throwRock
        
        super.init(chant: chant, cooldownDuration: cooldownDuration, speed: speed, cooldownTexture: cooldownTexture, textures: textures, damage: damage, spellType: spellType)
    }
}

class Fireball: Spell {
    init() {
        let chant = "ignitia"
        let cooldownDuration: CGFloat = 2.0
        let speed: CGFloat = 1.0
        let cooldownTexture = SKTexture(imageNamed: "cooldown-fireball")
        let textures = [
            SKTexture(imageNamed: "fireball-1"),
            SKTexture(imageNamed: "fireball-2"),
            SKTexture(imageNamed: "fireball-3"),
            SKTexture(imageNamed: "fireball-4")
        ]
        let damage = 10
        let spellType: SpellSfxType = .fireball
        
        super.init(chant: chant, cooldownDuration: cooldownDuration, speed: speed, cooldownTexture: cooldownTexture, textures: textures, damage: damage, spellType: spellType)
    }
}

class Iceblast: Spell {
    init() {
        let chant = "glacius acuti"
        let cooldownDuration: CGFloat = 4.0
        let speed: CGFloat = 1.0
        let cooldownTexture = SKTexture(imageNamed: "cooldown-iceblast")
        let textures = [
            SKTexture(imageNamed: "iceblast-1"),
            SKTexture(imageNamed: "iceblast-2"),
            SKTexture(imageNamed: "iceblast-3")
        ]
        let damage = 20
        let spellType: SpellSfxType = .iceblast
        
        super.init(chant: chant, cooldownDuration: cooldownDuration, speed: speed, cooldownTexture: cooldownTexture, textures: textures, damage: damage, spellType: spellType)
    }
}

class Shield: Spell {
    init() {
        let chant = "aegis"
        let cooldownDuration: CGFloat = 20.0
        let speed: CGFloat = 0
        let cooldownTexture = SKTexture(imageNamed: "cooldown-iceblast")
        let textures = [
            SKTexture(imageNamed: "shield"),
        ]
        let damage = 0
        let spellType: SpellSfxType = .shield
        
        super.init(chant: chant, cooldownDuration: cooldownDuration, speed: speed, cooldownTexture: cooldownTexture, textures: textures, damage: damage, spellType: spellType)
    }
    
    override func summonShield(player: Player) {
        isInCooldown = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownDuration) {
            self.isInCooldown = false
        }
        
        let spellNode: SKSpriteNode = SKSpriteNode(texture: self.textures[0])
        spellNode.name = "shield"
        spellNode.size = CGSize(width: 48.0, height: 48.0)
        
        player.spriteNode.addChild(spellNode)
        player.isShielded = true

        let waitAction = SKAction.wait(forDuration: 5.0)
        let removeSpellNodeAction = SKAction.run {
            spellNode.removeFromParent()
            player.isShielded = false
        }
        let actionSequence = SKAction.sequence([waitAction, removeSpellNodeAction])
        
        spellNode.run(actionSequence)
    }
}
