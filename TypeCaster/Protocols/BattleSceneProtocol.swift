import SpriteKit

protocol BattleSceneProtocol: SKScene {
    var floorCoordinates: [CGPoint] { get set }
    var wallCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    
    var enemy: Enemy { get set }
    var previousScene: ExplorationSceneProtocol { get set }
    
    func stopBattle()
    
    func goToPreviousScene()
}
