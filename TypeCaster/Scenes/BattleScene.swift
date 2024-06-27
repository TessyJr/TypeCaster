import SpriteKit

class BattleScene: SKScene, BattleSceneProtocol {
    var sceneCamera: SKCameraNode = SKCameraNode()
    var cooldownContainer: SKNode = SKNode()
    
    var isBattleOver: Bool = false
    
    var floorCoordinates: [CGPoint] = [CGPoint]()
    var wallCoordinates: [CGPoint] = [CGPoint]()
    
    var isSpellBookOpen: Bool = false
    var spellBookNode: SKSpriteNode = SKSpriteNode()
    
    var isSpellbookOpen: Bool = false
    
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
        
        for node in self.children {
            if let someTileMap = node as? SKTileMapNode {
                if someTileMap.name == "background" {
                    setUpWallsAndFloors(map: someTileMap)
                }
            }
        }
        
        setUpPlayer()
        setupSpells()
        setUpEnemy()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
    
    func goToStartScene() {
        let waitAction = SKAction.wait(forDuration: 4.0)
        let transitionAction = SKAction.run {
            if let scene = SKScene(fileNamed: "StartScene") {
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
            
        case 48:
            var spellbookNode: SKSpriteNode = SKSpriteNode()
            
            if player.spells.count == 3 {
                spellbookNode = SKSpriteNode(imageNamed: "spell-book-no-shield")
            } else if player.spells.count == 4 {
                spellbookNode = SKSpriteNode(imageNamed: "spell-book-with-shield")
            }
            
            spellbookNode.name = "spell-book"
            spellbookNode.position.y -= 20
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
                    player.castSpellInBattleScene(scene: self, chant: player.inputSpell.lowercased(), enemy: enemy)
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
