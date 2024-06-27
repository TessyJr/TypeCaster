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
        case "candles":
            return Candles(spriteNode: spriteNode, coordinate: coordinate)
        default:
            return nil
        }
    }
    
    func animateObject() {}
    
    func interact(scene: ExplorationSceneProtocol) {}
}
