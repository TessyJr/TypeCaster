import SpriteKit

protocol BattleSceneProtocol: SKScene {
    var sceneCamera: SKCameraNode { get set }
    var cooldownContainer: SKNode { get set }
    
    var isBattleOver: Bool { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    var wallCoordinates: [CGPoint] { get set }
    
    var isSpellBookOpen: Bool { get set }
    var spellBookNode: SKSpriteNode { get set }
    
    var player: Player { get set }
    
    var spellNode: SKSpriteNode? { get set }
    var spellCooldownNodes: [SKSpriteNode] { get set }
    
    var enemy: Enemy { get set }
    var enemyHealthBar: SKSpriteNode { get set }
    
    var previousScene: ExplorationSceneProtocol { get set }
    
    var attackNodes: [SKSpriteNode] { get set }
}

extension BattleSceneProtocol {
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
        player.direction = .right
        
        player.animateSprite()
        
        player.healthBarNode = sceneCamera.childNode(withName: "playerHealthBar") as! SKSpriteNode
        var playerHealthRatio = CGFloat(player.currentHealth) / CGFloat(player.maxHealth)
        if playerHealthRatio < 0 {
            playerHealthRatio = 0
        }
        player.healthBarNode.size.width = 256 * playerHealthRatio
        
        player.spellLabelNode = player.spriteNode.childNode(withName: "labelPlayerSpell") as! SKLabelNode
        player.inputSpell = ""
        player.spellLabelNode.text = player.inputSpell
        player.spellLabelNodeBackground = player.spriteNode.childNode(withName: "labelPlayerSpellBackground") as! SKSpriteNode
        
        cooldownContainer = sceneCamera.childNode(withName: "cooldown-container")!
        
        if spellCooldownNodes.isEmpty {
            var cooldownNodePosition = CGPoint(x: 0, y: 0)
            for spell in player.spells {
                let cooldownNode = SKSpriteNode(texture: spell.cooldownTexture)
                cooldownNode.position = cooldownNodePosition
                cooldownContainer.addChild(cooldownNode)
                
                spellCooldownNodes.append(cooldownNode)
                
                cooldownNodePosition.x += 40
            }
        }
    }
    
    func setUpEnemy() {
        enemy.spriteNode = childNode(withName: "enemy") as! SKSpriteNode
        enemy.animateSprite()
        
        enemyHealthBar = sceneCamera.childNode(withName: "enemyHealthBar") as! SKSpriteNode
    }
    
    func goToPreviousScene() {
        var waitAction: SKAction = SKAction()
        
        if self.previousScene.enemies.count == 1 {
            waitAction = SKAction.wait(forDuration: 3.0)
            enemy.dropKey(scene: self)
        } else {
            waitAction = SKAction.wait(forDuration: 1.0)
        }
        
        let transitionAction = SKAction.run {
            self.previousScene.player.currentHealth = self.player.currentHealth
            self.previousScene.player.isInBattle = false
            self.previousScene.defeatedEnemies.append(self.enemy)
            
            if let view = self.view {
                let transition = SKTransition.fade(withDuration: 1.0)
                view.presentScene(self.previousScene, transition: transition)
            }
        }
        
        let sequence = SKAction.sequence([waitAction, transitionAction])
        
        self.run(sequence)
    }
    
    func stopBattle() {
        self.removeAllActions()
        
        self.isBattleOver = true
        
        for node in self.children {
            if node.name == "pre-attack-node" || node.name == "spell" {
                node.removeAllActions()
                node.removeFromParent()
            }
        }
        
        for attackNode in self.attackNodes {
            attackNode.removeFromParent()
        }
        
        self.attackNodes.removeAll()
    }
}
