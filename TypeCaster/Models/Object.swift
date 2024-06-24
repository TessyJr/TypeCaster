import SpriteKit

class Object {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var coordinate: CGPoint = CGPoint()
    
    var name: String = String()
    
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, objectType: String) -> Object? {
        switch objectType {
        case "rocks":
            return Rocks(spriteNode: spriteNode, coordinate: coordinate)
        case "door":
            return Door(spriteNode: spriteNode, coordinate: coordinate)
        default:
            return nil
        }
    }
    
    func interact(player: Player) {}
}

class Rocks: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "rocks"
    }
    
    override func interact(player: Player) {
        player.spellLabelNode.text = "I think I can break these rocks with a spell"
        player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
    }
}

class Door: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "door"
    }
    
    override func interact(player: Player) {
        player.spellLabelNode.text = "This door is locked"
        player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
    }
}
