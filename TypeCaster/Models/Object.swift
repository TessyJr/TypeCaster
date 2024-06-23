import SpriteKit

class Object {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var coordinate: CGPoint = CGPoint()
    var objectType: String = ""
        
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, objectType: String) -> Object? {
        switch objectType {
        case "boxes":
            return Boxes(spriteNode: spriteNode, coordinate: coordinate, objectType: objectType)
        case "door":
            return Door(spriteNode: spriteNode, coordinate: coordinate, objectType: objectType)
        default:
            return nil
        }
    }
    
    func interact(player: Player) {}
}

class Boxes: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint, objectType: String) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.objectType = objectType
    }
    
    override func interact(player: Player) {
        player.spellLabelNode.text = "I think I can break these boxes with a spell"
        player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
    }
}

class Door: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint, objectType: String) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.objectType = objectType
    }
    
    override func interact(player: Player) {
        player.spellLabelNode.text = "This door is locked"
        player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
    }
}
