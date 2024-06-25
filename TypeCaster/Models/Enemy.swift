import SpriteKit

class Enemy {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    var coordinate: CGPoint = CGPoint()
    
    var name: String = String()
    
    var status: Status = .idle
    var currentHealth: Int = 0
    var maxHealth: Int = 0
    
    var attackInterval: CGFloat = 0
    
    var isLastEnemy: Bool = false
    
    // Factory method to create enemy based on type with customization
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, enemyType: String) -> Enemy? {
        switch enemyType {
        case "devil":
            return Devil(spriteNode: spriteNode, coordinate: coordinate)
        case "kraken":
            return Kraken(spriteNode: spriteNode, coordinate: coordinate)
        case "boss":
            return Boss(spriteNode: spriteNode, coordinate: coordinate)
        case "tutorial":
            return TutorialEnemy(spriteNode: spriteNode, coordinate: coordinate)
        default:
            return nil
        }
    }
    
    func startAttacking(scene: BattleScene, player: Player, completion: @escaping () -> Void) {}
    
    func animateSprite() {
        spriteNode.removeAllActions()
        
        var textures: [SKTexture] = []
        
        switch status {
        case .idle:
            for i in 1...2 {
                let textureName = "\(name)-idle-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
            
            spriteNode.run(repeatIdleAnimation)
        case .hurt:
            var textures: [SKTexture] = []
            for i in 1...2 {
                let textureName = "\(name)-hurt-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let hurtAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            
            spriteNode.run(hurtAnimation)
        case .dead:
            for i in 1...4 {
                let textureName = "\(name)-die-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let dieAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            
            spriteNode.run(dieAnimation)
            
        case .attacking:
            for i in 1...4 {
                let textureName = "\(name)-attack-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let attackAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            
            spriteNode.run(attackAnimation)
        default:
            break
        }
    }
    
    func getHurt(scene: BattleSceneProtocol, damage: Int) {
        currentHealth -= damage
        
        if currentHealth <= 0 {
            spriteNode.removeAllActions()
            scene.stopBattle()
            
            status = .dead
            animateSprite()
            
            scene.goToPreviousScene()
            
            return
        }
        
        status = .hurt
        animateSprite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.status = .idle
            self.animateSprite()
        }
    }
    
    func dropKey(scene: BattleSceneProtocol) {
        
        var keyTextures: [SKTexture] = []
        
        for i in 1...3 {
            let textureName = "flying-key-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            keyTextures.append(texture)
        }
        
        let keyNode: SKSpriteNode = SKSpriteNode(texture: keyTextures[2])
        keyNode.position = self.spriteNode.position
        
        
        let moveAnimation = SKAction.animate(with: keyTextures, timePerFrame: 0.3)
        let repeatAnimation = SKAction.repeatForever(moveAnimation)
        keyNode.run(repeatAnimation)
        
        scene.addChild(keyNode)
        
        let moveAction = SKAction.move(to: scene.player.spriteNode.position, duration: 2.5)
        let removeAction = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([moveAction, removeAction])
        AudioManager.shared.stopBgm()
        AudioManager.shared.playEnemyDropKeySfx(node: keyNode)
        
        keyNode.run(sequence)
    }
}

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
    
    // Random Tile Attack
    private func attack1Action(scene: BattleScene, player: Player) -> SKAction {
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(coordinate)
                }
            }
        }
        
        // Step 2: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 3: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.5)
        
        // Step 4: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            self.status = .idle
            self.animateSprite()
            
            for node in scene.children {
                if node.name == "pre-attack-node" {
                    node.removeFromParent()
                }
            }
        }
        
        // Step 5: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let trapdoorTexture = SKTexture(imageNamed: "fireball")
                let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
                trapdoorNode.position = coordinate
                trapdoorNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(trapdoorNode)
                scene.attackNodes.append(trapdoorNode)
            }
        }
        
        // Step 6: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.0)
        
        // Step 7: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for attackNode in scene.attackNodes {
                attackNode.removeFromParent()
            }
            
            scene.attackNodes.removeAll()
            attackCoordinates.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, waitAction2, removeAttackAction])
        
        return sequence
    }
    
    override func startAttacking(scene: BattleScene, player: Player, completion: @escaping () -> Void) {
        let waitAction = SKAction.wait(forDuration: attackInterval)
        
        // Randomly choose the first attack
        var attackAction = SKAction()
        let randomAttack = Int.random(in: 1...1)
        switch randomAttack {
        case 1:
            attackAction = self.attack1Action(scene: scene, player: player)
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

class Kraken: Enemy {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "kraken"
        self.currentHealth = 100
        self.maxHealth = 100
        self.attackInterval = 1.0
    }
    
    // Moving Rows Attack
    private func attack1Action(scene: BattleScene, player: Player) -> SKAction {
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
            uniqueRows.forEach { y in
                
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(CGPoint(x: firstColumn, y: y))
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
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
    
    override func startAttacking(scene: BattleScene, player: Player, completion: @escaping () -> Void) {
        let waitAction = SKAction.wait(forDuration: attackInterval)
        
        // Randomly choose the first attack
        var attackAction = SKAction()
        let randomAttack = Int.random(in: 1...1)
        switch randomAttack {
        case 1:
            attackAction = self.attack1Action(scene: scene, player: player)
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

class Boss: Enemy {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "boss"
        self.currentHealth = 200
        self.maxHealth = 200
        self.attackInterval = 0.5
    }
    
    // Random Tile Attack
    private func attackRandomTileAction(scene: BattleScene, player: Player) -> SKAction {
        var attackCoordinates = [CGPoint]()
        
        // Step 1: Get attack coordinates
        let getAttackCoordinatesAction = SKAction.run {
            scene.floorCoordinates.forEach { coordinate in
                let randomInt = Int.random(in: 1...2)
                
                if randomInt == 1 {
                    attackCoordinates.append(coordinate)
                }
            }
        }
        
        // Step 2: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 3: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.0)
        
        // Step 4: Remove pre-attack nodes
        let removePreAttackAction = SKAction.run {
            self.status = .idle
            self.animateSprite()
            
            for node in scene.children {
                if node.name == "pre-attack-node" {
                    node.removeFromParent()
                }
            }
        }
        
        // Step 5: Attack logic
        let attackAction = SKAction.run {
            for coordinate in attackCoordinates {
                let trapdoorTexture = SKTexture(imageNamed: "fireball")
                let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
                trapdoorNode.position = coordinate
                trapdoorNode.size = CGSize(width: 32, height: 32)
                
                scene.addChild(trapdoorNode)
                scene.attackNodes.append(trapdoorNode)
            }
        }
        
        // Step 6: Wait for 1 second
        let waitAction2 = SKAction.wait(forDuration: 1.2)
        
        // Step 7: Remove attack nodes
        let removeAttackAction = SKAction.run {
            for attackNode in scene.attackNodes {
                attackNode.removeFromParent()
            }
            
            scene.attackNodes.removeAll()
            attackCoordinates.removeAll()
        }
        
        // Combine actions into a sequence
        let sequence = SKAction.sequence([getAttackCoordinatesAction, preAttackAction, waitAction1, removePreAttackAction, attackAction, waitAction2, removeAttackAction])
        
        return sequence
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
            uniqueRows.forEach { y in
                
                let randomInt = Int.random(in: 1...5)
                
                if randomInt <= 3 {
                    attackCoordinates.append(CGPoint(x: firstColumn, y: y))
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.0)
        
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
            uniqueRows.forEach { y in
                
                let randomInt = Int.random(in: 1...5)
                
                if randomInt <= 3 {
                    attackCoordinates.append(CGPoint(x: firstColumn, y: y))
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.0)
        
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
            uniqueColumns.forEach { x in
                
                let randomInt = Int.random(in: 1...5)
                
                if randomInt <= 3 {
                    attackCoordinates.append(CGPoint(x: x, y: firstRow))
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.0)
        
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
            uniqueColumns.forEach { x in
                
                let randomInt = Int.random(in: 1...5)
                
                if randomInt <= 3 {
                    attackCoordinates.append(CGPoint(x: x, y: firstRow))
                }
            }
        }
        
        // Step 3: Pre-attack logic
        let preAttackAction = SKAction.run {
            self.status = .attacking
            self.animateSprite()
            
            for coordinate in attackCoordinates {
                let preAttackTexture = SKTexture(imageNamed: "fireball")
                let preAttackNode = SKSpriteNode(texture: preAttackTexture)
                preAttackNode.name = "pre-attack-node"
                preAttackNode.position = coordinate
                preAttackNode.size = CGSize(width: 32, height: 32)
                preAttackNode.alpha = 0.2
                
                scene.addChild(preAttackNode)
            }
        }
        
        // Step 4: Wait for 1.5 seconda
        let waitAction1 = SKAction.wait(forDuration: 1.0)
        
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
        let randomAttack = Int.random(in: 1...5)
        switch randomAttack {
        case 1:
            attackAction = self.attackRandomTileAction(scene: scene, player: player)
        case 2:
            attackAction = self.attackRightRowAction(scene: scene, player: player)
        case 3:
            attackAction = self.attackLeftRowAction(scene: scene, player: player)
        case 4:
            attackAction = self.attackTopColumnAction(scene: scene, player: player)
        case 5:
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

class TutorialEnemy: Enemy {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "devil"
        self.currentHealth = 30
        self.maxHealth = 30
        self.attackInterval = 0.0
    }
    
    override func startAttacking(scene: BattleScene, player: Player, completion: @escaping () -> Void) {}
}
