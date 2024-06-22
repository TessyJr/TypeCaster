import SpriteKit

class BattleScene: SKScene, BattleSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    var cooldownContainer: SKNode = SKNode()

    var isBattleOver: Bool = false
    
    var floorCoordinates: [CGPoint] = [CGPoint]()
    var wallCoordinates: [CGPoint] = [CGPoint]()
    
    var isSpellBookOpen: Bool = false
    var spellBookNode: SKSpriteNode = SKSpriteNode()
    
    var player: Player = Player()
    
    var spellNode: SKSpriteNode?
    var spellCooldownNodes: [SKSpriteNode] = []
    
    var enemy: Enemy = Enemy()
    var enemyHealthBar: SKSpriteNode = SKSpriteNode()
    
    var previousScene: ExplorationSceneProtocol = ExplorationScene1()
    
    var attackNodes: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        AudioManager.shared.playBgm(bgmType: .battle)
        
        sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        //        spellBookNode = SKSpriteNode(imageNamed: "spellBook")
        //        spellBookNode.zPosition = 20
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                }
            }
        }
        
        setUpPlayer()
        setUpEnemy()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.enemyAttackLoop()
        }
    }
    
    func enemyAttackLoop() {
        enemy.startAttacking(scene: self, player: self.player) {
            if !self.isBattleOver {
                self.enemyAttackLoop()
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
    
    func goToPreviousScene() {
        let waitAction = SKAction.wait(forDuration: 1.0)
        
        let transitionAction = SKAction.run {
            self.previousScene.player = self.player
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
    
    func goToStartScene() {
        let waitAction = SKAction.wait(forDuration: 4.0)
        let transitionAction = SKAction.run {
            if let scene = SKScene(fileNamed: "ExplorationScene1") {
                scene.scaleMode = .aspectFit
                
                if let view = self.view {
                    let transition = SKTransition.fade(withDuration: 1.0)
                    view.presentScene(scene, transition: transition)
                }
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
                node.removeFromParent()
            }
        }
        
        for attackNode in self.attackNodes {
            attackNode.removeFromParent()
        }
        
        self.attackNodes.removeAll()
    }
    
    override func keyDown(with event: NSEvent) {
        if player.status == .stunned || player.status == .dead || isBattleOver {
            return
        }
        
        switch event.keyCode {
        case 123:
            player.moveInBattleScene(scene: self, direction: .left)
            
        case 124:
            player.moveInBattleScene(scene: self, direction: .right)
            
        case 126:
            player.moveInBattleScene(scene: self, direction: .up)
            
        case 125:
            player.moveInBattleScene(scene: self, direction: .down)
            
        case 36:
            if player.inputSpell == "" {
                break
            }
            
            player.castSpellInBattleScene(scene: self, chant: player.inputSpell, enemy: enemy)
            
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
                    player.castSpellInBattleScene(scene: self, chant: player.inputSpell, enemy: enemy)
                    break
                }
            }
            
            player.inputSpell.append(event.characters!)
            player.spellLabelNode.text = player.inputSpell
            
            player.spellLabelNodeBackground.size.width = player.spellLabelNode.frame.width + 2
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        attackNodes.forEach { attackNode in
            if player.spriteNode.frame.intersects(attackNode.frame) {
                player.getDamage(scene: self)
            }
            
        }
        
        var playerHealthRatio = CGFloat(player.currentHealth) / CGFloat(player.maxHealth)
        if playerHealthRatio < 0 {
            playerHealthRatio = 0
        }
        player.healthBarNode.size.width = 256 * playerHealthRatio
        
        var enemyHealthRatio = CGFloat(enemy.currentHealth) / CGFloat(enemy.maxHealth)
        if enemyHealthRatio < 0 {
            enemyHealthRatio = 0
        }
        enemyHealthBar.size.width = 256 * enemyHealthRatio
    }
}
