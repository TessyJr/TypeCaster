import SpriteKit

class ExplorationScene3: SKScene, ExplorationSceneProtocol {
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
        AudioManager.shared.playBgm(bgmType: .exploration)
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                }
            }
        }
        
        setUpEnemies()
        setUpObjects()
        setUpDoor()
        setUpPlayer()
        setupSpells()
    }
    
    override func keyDown(with event: NSEvent) {
        if player.status == .stunned || player.isInBattle {
            return
        }
        
        switch event.keyCode {
        case 123:
            player.moveInExplorationScene(scene: self, direction: .left, completion: checkIfEnemyInPlayerRadius)
            
        case 124:
            player.moveInExplorationScene(scene: self, direction: .right, completion: checkIfEnemyInPlayerRadius)
            
        case 126:
            player.moveInExplorationScene(scene: self, direction: .up, completion: checkIfEnemyInPlayerRadius)
            
        case 125:
            player.moveInExplorationScene(scene: self, direction: .down, completion: checkIfEnemyInPlayerRadius)
            
        case 36:
            if player.inputSpell == "" {
                break
            }
            
            player.castSpellInExplorationScene(scene: self, chant: player.inputSpell.lowercased())
            
            player.inputSpell = ""
            player.spellLabelNode.text = player.inputSpell
            player.spellLabelNodeBackground.size.width = 0
            
        case 48:
            var spellbookNode: SKSpriteNode = SKSpriteNode()
            
            if player.spells.count == 3 {
                spellbookNode = SKSpriteNode(imageNamed: "spell-book-no-shield")
            } else if player.spells.count == 4 {
                spellbookNode = SKSpriteNode(imageNamed: "spell-book-with-shield")
            }
            
            spellbookNode.name = "spell-book"
            spellbookNode.zPosition = 20
            
            if isSpellbookOpen {
                if let node = sceneCamera.childNode(withName: "spell-book") {
                    node.removeFromParent()
                    isSpellbookOpen = false
                }
            } else {
                sceneCamera.addChild(spellbookNode)
                isSpellbookOpen = true
            }
            
        default:
            if event.keyCode == 49 {
                if player.inputSpell == "" {
                    player.interactWith(scene: self)
                    break
                }
            }
            
            player.inputSpell.append(event.characters!)
            player.spellLabelNode.text = player.inputSpell
            
            player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = player.spriteNode.position
        
        var playerHealthRatio = CGFloat(player.currentHealth) / CGFloat(player.maxHealth)
        if playerHealthRatio < 0 {
            playerHealthRatio = 0
        }
        player.healthBarNode.size.width = 256 * playerHealthRatio
        
        for (index, object) in objects.enumerated().reversed() {
            if let spellNode = spellNode, spellNode.frame.intersects(object.spriteNode.frame) {
                spellNode.removeAllActions()
                spellNode.removeFromParent()
                self.spellNode = nil
                
                object.spriteNode.removeFromParent()
                destroyedObjects.append(object)
                
                if let coordinateIndex = objectCoordinates.firstIndex(of: object.coordinate) {
                    objectCoordinates.remove(at: coordinateIndex)
                }
                
                objects.remove(at: index)
            }
        }
    }
}
