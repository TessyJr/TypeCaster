import SpriteKit

protocol BattleSceneProtocol: SKScene {
    var cooldownContainer: SKNode { get set }

    
    var floorCoordinates: [CGPoint] { get set }
    var wallCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    
    var enemy: Enemy { get set }
    var previousScene: ExplorationSceneProtocol { get set }
    
    var spellNode: SKSpriteNode? { get set }
    var spellCooldownNodes: [SKSpriteNode] { get set }
    
    func stopBattle()
    
    func goToPreviousScene()
}
