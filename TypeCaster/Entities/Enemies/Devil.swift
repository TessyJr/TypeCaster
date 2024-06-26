import SpriteKit

class Devil: Enemy {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "devil"
        self.currentHealth = 100
        self.maxHealth = 100
        self.attackInterval = 1.0
    }
    
    // Moving Right Rows Attack
    private func attackRightRowAction(scene: BattleScene, player: Player) -> SKAction {
        var uniqueRows = [CGFloat]()
        var firstColumn: CGFloat = -1000.0
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get unique rows
        let getUniqueRowsAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let y = coordinate.y
                if !uniqueRows.contains(y) {
                    uniqueRows.append(y)
                }
                
                let x = coordinate.x
                if x > firstColumn {
                    firstColumn = x
                }
            }
        }
        
        // Step 2: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            for y in uniqueRows {
                
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(CGPoint(x: firstColumn, y: y))
                }
                
                if attackCoordinates.count == 6 {
                    break
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "attack-preview")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.5)
        
        // Step 5: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            self.status = .idle
            self.animateSprite()
            
            for node in scene.children {
                if node.name == "pre-attack-node" {
                    node.removeFromParent()
                }
            }
        }
        
        // Step 6: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let enemyAttackTexture = SKTexture(imageNamed: "fireball")
                let enemyAttackNode = SKSpriteNode(texture: enemyAttackTexture)
                enemyAttackNode.position = coordinate
                enemyAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(enemyAttackNode)
                scene.attackNodes.append(enemyAttackNode)
                
                let moveLeftAction = SKAction.moveBy(x: -256, y: 0, duration: 0.75)
                let removeNodeAction = SKAction.removeFromParent()
                let moveAndRemoveSequence = SKAction.sequence([moveLeftAction, removeNodeAction])
                
                enemyAttackNode.run(moveAndRemoveSequence)
            }
        }
        
        // Step 7: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.0)
        
        // Step 8: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for attackNode in scene.attackNodes {
                attackNode.removeFromParent()
            }
            
            scene.attackNodes.removeAll()
            attackCoordinates.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getUniqueRowsAction, getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, waitAction2, removeAttackAction])
        
        return sequence
    }
    
    // Moving Left Rows Attack
    private func attackLeftRowAction(scene: BattleScene, player: Player) -> SKAction {
        var uniqueRows = [CGFloat]()
        var firstColumn: CGFloat = 1000.0
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get unique rows
        let getUniqueRowsAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let y = coordinate.y
                if !uniqueRows.contains(y) {
                    uniqueRows.append(y)
                }
                
                let x = coordinate.x
                if x < firstColumn {
                    firstColumn = x
                }
            }
        }
        
        // Step 2: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            for y in uniqueRows {
                
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(CGPoint(x: firstColumn, y: y))
                }
                
                if attackCoordinates.count == 6 {
                    break
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "attack-preview")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.5)
        
        // Step 5: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            self.status = .idle
            self.animateSprite()
            
            for node in scene.children {
                if node.name == "pre-attack-node" {
                    node.removeFromParent()
                }
            }
        }
        
        // Step 6: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let enemyAttackTexture = SKTexture(imageNamed: "fireball")
                let enemyAttackNode = SKSpriteNode(texture: enemyAttackTexture)
                enemyAttackNode.position = coordinate
                enemyAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(enemyAttackNode)
                scene.attackNodes.append(enemyAttackNode)
                
                let moveLeftAction = SKAction.moveBy(x: 256, y: 0, duration: 0.75)
                let removeNodeAction = SKAction.removeFromParent()
                let moveAndRemoveSequence = SKAction.sequence([moveLeftAction, removeNodeAction])
                
                enemyAttackNode.run(moveAndRemoveSequence)
            }
        }
        
        // Step 7: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.0)
        
        // Step 8: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for attackNode in scene.attackNodes {
                attackNode.removeFromParent()
            }
            
            scene.attackNodes.removeAll()
            attackCoordinates.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getUniqueRowsAction, getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, waitAction2, removeAttackAction])
        
        return sequence
    }
    
    // Moving Top Column Attack
    private func attackTopColumnAction(scene: BattleScene, player: Player) -> SKAction {
        var uniqueColumns = [CGFloat]()
        var firstRow: CGFloat = -1000.0
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get unique rows
        let getUniqueRowsAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let x = coordinate.x
                if !uniqueColumns.contains(x) {
                    uniqueColumns.append(x)
                }
                
                let y = coordinate.y
                if y > firstRow {
                    firstRow = y
                }
            }
        }
        
        // Step 2: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            for x in uniqueColumns {
                
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(CGPoint(x: x, y: firstRow))
                }
                
                if attackCoordinates.count == 6 {
                    break
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "attack-preview")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.5)
        
        // Step 5: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            self.status = .idle
            self.animateSprite()
            
            for node in scene.children {
                if node.name == "pre-attack-node" {
                    node.removeFromParent()
                }
            }
        }
        
        // Step 6: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let enemyAttackTexture = SKTexture(imageNamed: "fireball")
                let enemyAttackNode = SKSpriteNode(texture: enemyAttackTexture)
                enemyAttackNode.position = coordinate
                enemyAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(enemyAttackNode)
                scene.attackNodes.append(enemyAttackNode)
                
                let moveLeftAction = SKAction.moveBy(x: 0, y: -256, duration: 0.75)
                let removeNodeAction = SKAction.removeFromParent()
                let moveAndRemoveSequence = SKAction.sequence([moveLeftAction, removeNodeAction])
                
                enemyAttackNode.run(moveAndRemoveSequence)
            }
        }
        
        // Step 7: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.2)
        
        // Step 8: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for attackNode in scene.attackNodes {
                attackNode.removeFromParent()
            }
            
            scene.attackNodes.removeAll()
            attackCoordinates.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getUniqueRowsAction, getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, waitAction2, removeAttackAction])
        
        return sequence
    }
    
    // Moving Bottom Column Attack
    private func attackBottomColumnAction(scene: BattleScene, player: Player) -> SKAction {
        var uniqueColumns = [CGFloat]()
        var firstRow: CGFloat = 1000.0
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get unique rows
        let getUniqueRowsAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let x = coordinate.x
                if !uniqueColumns.contains(x) {
                    uniqueColumns.append(x)
                }
                
                let y = coordinate.y
                if y < firstRow {
                    firstRow = y
                }
            }
        }
        
        // Step 2: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            for x in uniqueColumns {
                
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(CGPoint(x: x, y: firstRow))
                }
                
                if attackCoordinates.count == 6 {
                    break
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "attack-preview")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.5)
        
        // Step 5: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            self.status = .idle
            self.animateSprite()
            
            for node in scene.children {
                if node.name == "pre-attack-node" {
                    node.removeFromParent()
                }
            }
        }
        
        // Step 6: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let enemyAttackTexture = SKTexture(imageNamed: "fireball")
                let enemyAttackNode = SKSpriteNode(texture: enemyAttackTexture)
                enemyAttackNode.position = coordinate
                enemyAttackNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(enemyAttackNode)
                scene.attackNodes.append(enemyAttackNode)
                
                let moveLeftAction = SKAction.moveBy(x: 0, y: 256, duration: 0.75)
                let removeNodeAction = SKAction.removeFromParent()
                let moveAndRemoveSequence = SKAction.sequence([moveLeftAction, removeNodeAction])
                
                enemyAttackNode.run(moveAndRemoveSequence)
            }
        }
        
        // Step 7: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.2)
        
        // Step 8: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for attackNode in scene.attackNodes {
                attackNode.removeFromParent()
            }
            
            scene.attackNodes.removeAll()
            attackCoordinates.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getUniqueRowsAction, getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, waitAction2, removeAttackAction])
        
        return sequence
    }
    
    override func startAttacking(scene: BattleScene, player: Player, completion: @escaping () -> Void) {
        let waitAction = SKAction.wait(forDuration: attackInterval)
        
        // Randomly choose the first attack
        var attackAction = SKAction()
        let randomAttack = Int.random(in: 1...4)
        switch randomAttack {
        case 1:
            attackAction = self.attackRightRowAction(scene: scene, player: player)
        case 2:
            attackAction = self.attackLeftRowAction(scene: scene, player: player)
        case 3:
            attackAction = self.attackTopColumnAction(scene: scene, player: player)
        case 4:
            attackAction = self.attackBottomColumnAction(scene: scene, player: player)
        default:
            return
        }
        
        let attackCompleteAction = SKAction.run {
            completion()
        }
        
        let attackSequence = SKAction.sequence([waitAction, attackAction, attackCompleteAction])
        
        // Run the repeating sequence action
        scene.run(attackSequence)
    }
}

