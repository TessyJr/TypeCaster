import SpriteKit

protocol ExplorationSceneProtocol: SKScene {
    var cooldownContainer: SKNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    var wallCoordinates: [CGPoint] { get set }
    var objectCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    
    var defeatedEnemies: [Enemy] { get set }
    
    var spellNode: SKSpriteNode? { get set }
    var spellCooldownNodes: [SKSpriteNode] { get set }
}
