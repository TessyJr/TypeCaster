import SpriteKit

class Enemy {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    var coordinate: CGPoint = CGPoint()
    
    var name: String = String()
    
    var status: Status = .idle
    var currentHealth: Int = 0
    var maxHealth: Int = 0
    
    var attackInterval: CGFloat = 0
    
    // Factory method to create enemy based on type with customization
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, enemyType: String) -> Enemy? {
        switch enemyType {
        case "devil":
            return Devil(spriteNode: spriteNode, coordinate: coordinate)
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
