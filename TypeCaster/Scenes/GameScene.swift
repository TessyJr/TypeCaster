import SpriteKit

class GameScene: SKScene, ExplorationSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    
    var floorCoordinates: [CGPoint] = []
    var wallCoordinates: [CGPoint] = []
    var objectCoordinates: [CGPoint] = []
    
    var player: Player = Player()
    var lastPlayerCoordinate: CGPoint?
    var lastPlayerDirection: Direction?
    
    var spellNode: SKSpriteNode?
    
    var enemies: [Enemy] = []
    var defeatedEnemies: [Enemy] = []
    
    var objects: [Object] = []
    var destroyedObjects: [Object] = []
    
    func setUpWallsAndFloors(map: SKTileMapNode) {
        let tileMap = map
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    
                    let tileCoordinate = CGPoint(x: x, y: y)
                    
                    if let isWall = tileDefinition.userData?["isWall"] as? Bool {
                        if isWall {
                            wallCoordinates.append(tileCoordinate)
                        }
                    } else if let isFloor = tileDefinition.userData?["isFloor"] as? Bool {
                        if isFloor {
                            floorCoordinates.append(tileCoordinate)
                        }
                    }
                }
            }
        }
    }
    
    func setUpPlayer() {
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        
        if let lastPlayerCoordinate = self.lastPlayerCoordinate {
            player.spriteNode.position = lastPlayerCoordinate
        }
        
        if let lastPlayerDirection = self.lastPlayerDirection {
            player.direction = lastPlayerDirection
        }
        
        player.animateSprite()
        
        player.radiusNode = childNode(withName: "player-radius") as! SKSpriteNode
        
        player.healthBarNode = player.spriteNode.childNode(withName: "playerHealthBar") as! SKSpriteNode
        var playerHealthRatio = CGFloat(player.currentHealth) / CGFloat(player.maxHealth)
        if playerHealthRatio < 0 {
            playerHealthRatio = 0
        }
        player.healthBarNode.size.width = 32 * playerHealthRatio
        
        player.spellLabelNode = player.spriteNode.childNode(withName: "labelPlayerSpell") as! SKLabelNode
        player.inputSpell = ""
        player.spellLabelNode.text = player.inputSpell
        player.spellLabelNodeBackground = player.spriteNode.childNode(withName: "labelPlayerSpellBackground") as! SKSpriteNode
        
        sceneCamera.removeAllChildren()
        var hudPosition = CGPoint(x: -700, y: -400)
        for spell in player.spells {
            let hudSpriteNode = spell.hudSpriteNode
            hudSpriteNode.size = CGSize(width: 64.0, height: 64.0)
            hudSpriteNode.position = hudPosition
            sceneCamera.addChild(hudSpriteNode)
            
            hudPosition.x += 96
        }
    }
    
    func setUpEnemies() {
        enemies.removeAll()
        
        for node in self.children {
            if node.name == "enemy" {
                if let enemySpriteNode = node as? SKSpriteNode,
                   let enemyType = enemySpriteNode.userData?["enemyType"] as? String {
                    
                    if let enemy = Enemy.create(spriteNode: enemySpriteNode, coordinate: enemySpriteNode.position, enemyType: enemyType) {
                        if defeatedEnemies.contains(where: { $0.coordinate == enemy.coordinate }) {
                            if let index = enemies.firstIndex(where: { $0.coordinate == enemy.coordinate }) {
                                enemies.remove(at: index)
                            }
                            
                            enemySpriteNode.removeFromParent()
                        } else {
                            enemies.append(enemy)
                        }
                    }
                }
            }
        }
    }
    
    func setUpObjects() {
        objects.removeAll()
        objectCoordinates.removeAll()
        
        for node in self.children {
            if node.name == "object" || node.name == "door" {
                if let objectSpriteNode = node as? SKSpriteNode,
                   let objectType = objectSpriteNode.userData?["objectType"] as? String {
                    
                    if objectType == "door" && enemies.isEmpty {
                        objectSpriteNode.removeFromParent()
                        continue
                    }
                    
                    if let object = Object.create(spriteNode: objectSpriteNode, coordinate: objectSpriteNode.position, objectType: objectType) {
                        if destroyedObjects.contains(where: { $0.coordinate == object.coordinate }) {
                            if let index = objects.firstIndex(where: { $0.coordinate == object.coordinate }) {
                                objects.remove(at: index)
                            }
                            
                            objectSpriteNode.removeFromParent()
                        } else {
                            objectCoordinates.append(object.coordinate)
                            objects.append(object)
                        }
                    }
                }
            }
        }
    }
    
    func checkIfEnemyInPlayerRadius() {
        enemies.forEach { enemy in
            if player.radiusNode.frame.intersects(enemy.spriteNode.frame) {
                player.isInBattle = true
                
                let exclamationSpriteNode = SKSpriteNode(imageNamed: "exclamation")
                exclamationSpriteNode.zPosition = -1
                exclamationSpriteNode.scale(to: CGSize(width: 16.0, height: 16.0))
                exclamationSpriteNode.run(SKAction.move(by: CGVector(dx: 0, dy: 24.0), duration: 0.1))
                
                enemy.spriteNode.addChild(exclamationSpriteNode)
                
                let waitAction = SKAction.wait(forDuration: 1.0)
                let transitionAction = SKAction.run {
                    if let battleScene = SKScene(fileNamed: "BattleScene") as? BattleSceneProtocol {
                        print("Battle Scene found!")
                        self.lastPlayerCoordinate = self.player.spriteNode.position
                        self.lastPlayerDirection = self.player.direction
                        
                        battleScene.scaleMode = .aspectFill
                        battleScene.player = self.player
                        battleScene.enemy = enemy
                        battleScene.previousScene = self
                        
                        if let view = self.view {
                            print("Go to Battle Scene")
                            let transition = SKTransition.fade(withDuration: 1.0)
                            view.presentScene(battleScene, transition: transition)
                        }
                    }
                }
                
                let sequence = SKAction.sequence([waitAction, transitionAction])
                self.run(sequence)
                
                return
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
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
        setUpPlayer()
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
            
            player.castSpellInExplorationScene(scene: self, chant: player.inputSpell)
            
            player.inputSpell = ""
            player.spellLabelNode.text = player.inputSpell
            
            player.spellLabelNodeBackground.size.width = 0
            
            //        case 48:
            //            if isSpellBookOpen {
            //                isSpellBookOpen = false
            //                spellBookNode.removeFromParent()
            //            } else {
            //                isSpellBookOpen = true
            //                sceneCamera.addChild(spellBookNode)
            //            }
            
        default:
            if event.keyCode == 49 {
                if player.inputSpell == "" {
                    player.interactWithObject(objects: objects)
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
        
        for (index, object) in objects.enumerated().reversed() {
            if let spellNode = spellNode, spellNode.frame.intersects(object.spriteNode.frame) {
                spellNode.removeAllActions()
                spellNode.removeFromParent()
                self.spellNode = nil
                
                if object.name == "door" {
                    continue
                }
                
                object.spriteNode.removeFromParent()
                destroyedObjects.append(object)
                
                // Remove object from objectCoordinates safely
                if let coordinateIndex = objectCoordinates.firstIndex(of: object.coordinate) {
                    objectCoordinates.remove(at: coordinateIndex)
                }
                
                // Remove object from objects array
                objects.remove(at: index)
            }
        }
    }
}
