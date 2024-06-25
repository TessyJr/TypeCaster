import SpriteKit

protocol ExplorationSceneProtocol: SKScene {
    var sceneCamera: SKCameraNode { get set }
    var cooldownContainer: SKNode { get set }
    
    var floorCoordinates: [CGPoint] { get set }
    var wallCoordinates: [CGPoint] { get set }
    var objectCoordinates: [CGPoint] { get set }
    var npcCoordinates: [CGPoint] { get set }
    
    var player: Player { get set }
    var lastPlayerCoordinate: CGPoint? { get set }
    var lastPlayerDirection: Direction? { get set }
    
    var spellNode: SKSpriteNode? { get set }
    var spellCooldownNodes: [SKSpriteNode] { get set }
    
    var isSpellbookOpen: Bool { get set }
    
    var enemies: [Enemy] { get set }
    var defeatedEnemies: [Enemy] { get set }
    
    var objects: [Object] { get set }
    var destroyedObjects: [Object] { get set }
    
    var npcs: [NPC] { get set }
    
    var nextSceneCoordinate: CGPoint { get set }
}

extension ExplorationSceneProtocol {
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
    
    func setupSpells() {
        for spell in player.spells {
            spell.isInCooldown = false
            spell.cooldownTimer?.invalidate()
            spell.cooldownTimer = nil
        }
        
        cooldownContainer = sceneCamera.childNode(withName: "cooldown-container")!
        
        cooldownContainer.removeAllChildren()
        spellCooldownNodes.removeAll()
        
        var cooldownNodePosition = CGPoint(x: 0, y: 0)
        for spell in player.spells {
            let cooldownNode = SKSpriteNode(texture: spell.cooldownTexture)
            cooldownNode.position = cooldownNodePosition
            cooldownContainer.addChild(cooldownNode)
            
            spellCooldownNodes.append(cooldownNode)
            
            cooldownNodePosition.x += 40
        }
    }
    
    func setUpPlayer() {
        player.spriteNode = childNode(withName: "player") as! SKSpriteNode
        player.spriteNode.position.x = round(player.spriteNode.position.x)
        player.spriteNode.position.y = round(player.spriteNode.position.y)
        
        if let lastPlayerCoordinate = self.lastPlayerCoordinate {
            player.spriteNode.position = lastPlayerCoordinate
        }
        
        if let lastPlayerDirection = self.lastPlayerDirection {
            player.direction = lastPlayerDirection
        }
        
        player.animateSprite()
        
        if let radiusNode = childNode(withName: "player-radius") as? SKSpriteNode {
            player.radiusNode = radiusNode
        }
        
        if let healthBarNode = sceneCamera.childNode(withName: "playerHealthBar") as? SKSpriteNode {
            player.healthBarNode = healthBarNode
            var playerHealthRatio = CGFloat(player.currentHealth) / CGFloat(player.maxHealth)
            if playerHealthRatio < 0 {
                playerHealthRatio = 0
                
                player.healthBarNode.size.width = 256 * playerHealthRatio
            }
        }
        
        if let spellLabelNode = player.spriteNode.childNode(withName: "labelPlayerSpell") as? SKLabelNode {
            player.spellLabelNode = spellLabelNode
            player.inputSpell = ""
            player.spellLabelNode.text = player.inputSpell
        }
        
        if let spellLabelNodeBackground = player.spriteNode.childNode(withName: "labelPlayerSpellBackground") as? SKSpriteNode {
            player.spellLabelNodeBackground = spellLabelNodeBackground
            player.spellLabelNodeBackground.size.width = 0
        }
    }
    
    func setUpEnemies() {
        enemies.removeAll()
        
        for node in self.children {
            if node.name == "enemy" {
                if let enemySpriteNode = node as? SKSpriteNode,
                   let enemyType = enemySpriteNode.userData?["enemyType"] as? String {
                    enemySpriteNode.position.x = round(enemySpriteNode.position.x)
                    enemySpriteNode.position.y = round(enemySpriteNode.position.y)
                    
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
            if node.name == "object" {
                if let objectSpriteNode = node as? SKSpriteNode,
                   let objectType = objectSpriteNode.userData?["objectType"] as? String {
                    objectSpriteNode.position.x = round(objectSpriteNode.position.x)
                    objectSpriteNode.position.y = round(objectSpriteNode.position.y)
                    
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
    
    func setUpDoor() {
        for node in self.children {
            if node.name == "door" {
                if let objectSpriteNode = node as? SKSpriteNode {
                    if enemies.isEmpty {
                        if let index = wallCoordinates.firstIndex(of: objectSpriteNode.position) {
                            wallCoordinates.remove(at: index)
                        }
                        
                        floorCoordinates.append(objectSpriteNode.position)
                        
                        nextSceneCoordinate = objectSpriteNode.position
                        
                        objectSpriteNode.texture = SKTexture(imageNamed: "door-open")
                    } else {
                        wallCoordinates.append(objectSpriteNode.position)
                    }
                }
            }
        }
    }
    
    func setUpNPCS() {
        if npcCoordinates.isEmpty {
            for node in self.children {
                if node.name == "npc" {
                    if let npcSpriteNode = node as? SKSpriteNode,
                       let npcType = npcSpriteNode.userData?["npcType"] as? String {
                        npcSpriteNode.position.x = round(npcSpriteNode.position.x)
                        npcSpriteNode.position.y = round(npcSpriteNode.position.y)
                        
                        if let npc = NPC.create(spriteNode: npcSpriteNode, coordinate: npcSpriteNode.position, npcType: npcType) {
                            npc.status = .idle
                            npc.animateSprite()
                            
                            npcCoordinates.append(npc.coordinate)
                            npcs.append(npc)
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
                AudioManager.shared.playEnemyFoundSfx(node: enemy.spriteNode)
                
                let waitAction = SKAction.wait(forDuration: 1.0)
                let transitionAction = SKAction.run {
                    if let battleScene = SKScene(fileNamed: "BattleScene") as? BattleSceneProtocol {
                        self.lastPlayerCoordinate = self.player.spriteNode.position
                        self.lastPlayerDirection = self.player.direction
                        
                        battleScene.scaleMode = .aspectFill
                        //                        battleScene.player.currentHealth = self.player.currentHealth
                        battleScene.player = self.player
                        
                        //                        for spell in self.player.spells {
                        //                            battleScene.player.spells.append(spell)
                        //                        }
                        
                        battleScene.enemy = enemy
                        battleScene.previousScene = self
                        
                        if let view = self.view {
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
}
