import SpriteKit

class Object {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    var coordinate: CGPoint = CGPoint()
    var textures: [SKTexture] = []
    
    var isDestructible: Bool = false
    
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, objectType: String) -> Object? {
        switch objectType {
        case "boxes":
            return Boxes(spriteNode: spriteNode, coordinate: coordinate)
        case "fountain":
            return Fountain(spriteNode: spriteNode, coordinate: coordinate)
        case "spell-chest":
            return SpellChest(spriteNode: spriteNode, coordinate: coordinate)
        default:
            return nil
        }
    }
    
    func animateObject() {}
    
    func interact(scene: ExplorationSceneProtocol) {}
}

class Boxes: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = true
    }
    
    override func interact(scene: ExplorationSceneProtocol) {
        scene.player.spellLabelNode.text = "I think I can break these rocks with a spell"
        scene.player.spellLabelNodeBackground.size.width = scene.player.spellLabelNode.frame.width + 2
    }
}

class Fountain: Object {
    var isActive: Bool = true
    
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = false
        
        self.animateObject()
    }
    
    override func animateObject() {
        spriteNode.removeAllActions()
        
        if isActive {
            for i in 1...3 {
                let textureName = "fountain-active-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let activeAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            let repeatedActiveAnimation = SKAction.repeatForever(activeAnimation)
            
            spriteNode.run(repeatedActiveAnimation)
        } else {
            for i in 1...4 {
                let textureName = "fountain-inactive-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let inactiveAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            spriteNode.run(inactiveAnimation)
        }
    }
    
    override func interact(scene: ExplorationSceneProtocol) {
        if isActive {
            scene.player.spellLabelNode.text = "That's refreshing!"
            scene.player.spellLabelNodeBackground.size.width = scene.player.spellLabelNode.frame.width + 2
            
            AudioManager.shared.playPlayerStateSfx(node: scene.player.spriteNode, playerState: .healing)
            scene.player.currentHealth += 20
            
            if scene.player.currentHealth > scene.player.maxHealth {
                scene.player.currentHealth = scene.player.maxHealth
            }
            
            isActive = false
            animateObject()
        } else {
            scene.player.spellLabelNode.text = "The fountain is empty"
            scene.player.spellLabelNodeBackground.size.width = scene.player.spellLabelNode.frame.width + 2
        }
    }
}

class SpellChest: Object {
    var isOpened = false
    
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = false
    }
    
    override func interact(scene: ExplorationSceneProtocol) {
        if !isOpened {
            isOpened = true
            spriteNode.texture = SKTexture(imageNamed: "chest-open")
            
            scene.player.spells.append(Shield())
            
            scene.setupSpells()
            
            let labelNode = SKLabelNode()
            labelNode.fontName = "Pixel Times"
            labelNode.fontSize = 12.0
            labelNode.text = "New spell added to your spell book!"
            labelNode.position.y += 21.0
            
            let labelNodeBackground = SKSpriteNode()
            labelNodeBackground.color = .black
            labelNodeBackground.alpha = 0.8
            labelNodeBackground.size.height = 16.0
            labelNodeBackground.size.width = labelNode.frame.width + 2
            labelNodeBackground.position.y += 26.0
            
            spriteNode.addChild(labelNodeBackground)
            spriteNode.addChild(labelNode)
            
            let waitAction = SKAction.wait(forDuration: 2.0)
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([waitAction, fadeOutAction, removeAction])
            
            labelNode.run(sequence)
            labelNodeBackground.run(sequence)
        }
    }
}
