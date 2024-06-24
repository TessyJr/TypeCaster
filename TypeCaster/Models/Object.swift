import SpriteKit

class Object {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    var coordinate: CGPoint = CGPoint()
    var textures: [SKTexture] = []
    
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, objectType: String) -> Object? {
        switch objectType {
        case "boxes":
            return Boxes(spriteNode: spriteNode, coordinate: coordinate)
        case "fountain":
            return Fountain(spriteNode: spriteNode, coordinate: coordinate)
        default:
            return nil
        }
    }
    
    func animateObject() {}
    
    func interact(player: Player) {}
}

class Boxes: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
    }
    
    override func interact(player: Player) {
        player.spellLabelNode.text = "I think I can break these rocks with a spell"
        player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
    }
}

class Fountain: Object {
    var isActive: Bool = true
    
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
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
    
    override func interact(player: Player) {
        if isActive {
            player.spellLabelNode.text = "That's refreshing!"
            player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
            
            player.currentHealth += 10
            
            if player.currentHealth > player.maxHealth {
                player.currentHealth = player.maxHealth
            }
            
            isActive = false
            animateObject()
        } else {
            player.spellLabelNode.text = "The fountain is empty"
            player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
        }
    }
}
