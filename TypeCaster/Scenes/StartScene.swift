import SpriteKit

class StartScene: SKScene, ExplorationSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    var cooldownContainer: SKNode = SKNode()
    
    var floorCoordinates: [CGPoint] = []
    var wallCoordinates: [CGPoint] = []
    var objectCoordinates: [CGPoint] = []
    var npcCoordinates: [CGPoint] = []
    
    var player: Player = Player()
    var lastPlayerCoordinate: CGPoint?
    var lastPlayerDirection: Direction?
    
    var isSpellbookOpen: Bool = false
    
    var spellNode: SKSpriteNode?
    var spellCooldownNodes: [SKSpriteNode] = []
    
    var enemies: [Enemy] = []
    var defeatedEnemies: [Enemy] = []
    
    var objects: [Object] = []
    var destroyedObjects: [Object] = []
    
    var npcs: [NPC] = []
    
    var nextSceneCoordinate: CGPoint = CGPoint()
    
    override func didMove(to view: SKView) {
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                }
            }
        }
        
        setUpNPCS()
        setUpObjects()
        setUpPlayer()
        
        guard let instructionLabel = childNode(withName: "instruction") as? SKLabelNode else {
               return
        }
           
           // Create the actions to change alpha
        let setAlphaToZero = SKAction.run { instructionLabel.alpha = 0.0 }
            let setAlphaToOne = SKAction.run { instructionLabel.alpha = 1.0 }
            let waitAction1 = SKAction.wait(forDuration: 0.75)
        let waitAction2 = SKAction.wait(forDuration: 0.75)
        
//        let setAlphaToZero = SKAction.run { instructionLabel.position.y += 1.0 }
//        let setAlphaToOne = SKAction.run { instructionLabel.position.y -= 1.0 }
//            let waitAction1 = SKAction.wait(forDuration: 0.25)
//        let waitAction2 = SKAction.wait(forDuration: 0.25)
            
            // Create the sequence and repeat forever action
            let sequence = SKAction.sequence([setAlphaToOne, waitAction1, setAlphaToZero, waitAction2])
            let repeatForever = SKAction.repeatForever(sequence)
        
           // Run the action on the start scene node
           instructionLabel.run(repeatForever)
    }

    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            player.moveInExplorationScene(scene: self, direction: .left, completion: checkIfEnemyInPlayerRadius)
            
        case 124:
            player.moveInExplorationScene(scene: self, direction: .right, completion: checkIfEnemyInPlayerRadius)
            
        case 126:
            player.moveInExplorationScene(scene: self, direction: .up, completion: checkIfEnemyInPlayerRadius)
            
        case 125:
            player.moveInExplorationScene(scene: self, direction: .down, completion: checkIfEnemyInPlayerRadius)
            
        case 49:
            if let nextScene = SKScene(fileNamed: "ExplorationScene1") as? ExplorationSceneProtocol {
                if let view = self.view {
                    let transition = SKTransition.fade(withDuration: 1.0)
                    view.presentScene(nextScene, transition: transition)
                }
            }
            
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {}
}
