import SpriteKit

class Player {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    var spellLabelNode: SKLabelNode = SKLabelNode()
    var spellLabelNodeBackground: SKSpriteNode = SKSpriteNode()
    var healthBarNode: SKSpriteNode = SKSpriteNode()
    var radiusNode: SKSpriteNode = SKSpriteNode()
    
    var status: Status = .idle
    var direction: Direction = .down
    
    let moveAmount: CGFloat = 32.0
    var moveSpeed: CGFloat = 0.2
    
    var currentHealth: Int = 50
    var maxHealth: Int = 50
    
    var inputSpell: String = ""
    var spells: [Spell] = [Rock(), Fireball(), Iceblast()]
    
    var isInBattle: Bool = false
    
    var isInvincible: Bool = false
    var invincibleTimer: Timer?
    
    var isSpellBookOpen: Bool = false
    var spellBookNode: SKSpriteNode = SKSpriteNode()
    
    func animateSprite() {
        var textures: [SKTexture] = []
        
        switch status {
        case .attacking:
            if isInBattle {
                for i in 1...3 {
                    let textureName = "player-attack-right-\(i)"
                    let texture = SKTexture(imageNamed: textureName)
                    textures.append(texture)
                }
            } else {
                for i in 1...3 {
                    let textureName = "player-attack-\(direction)-\(i)"
                    let texture = SKTexture(imageNamed: textureName)
                    textures.append(texture)
                }
            }
            
            let attackAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            spriteNode.run(attackAnimation)
        case .moving:
            for i in 1...2 {
                let textureName = "player-move-\(direction)-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let moveAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            spriteNode.run(moveAnimation)
        case .idle:
            for i in 1...2 {
                let textureName = "player-idle-\(direction)-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
            
            spriteNode.run(repeatIdleAnimation)
        case .stunned:
            for i in 1...2 {
                let textureName = "player-stunned-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let stunnedAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            let repeatStunnedAnimation = SKAction.repeatForever(stunnedAnimation)
            
            spriteNode.run(repeatStunnedAnimation)
        case .hurt:
            for i in 1...2 {
                let textureName = "player-hurt-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let hurtAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            
            spriteNode.run(hurtAnimation)
        case .dead:
            for i in 1...7 {
                let textureName = "player-dead-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let deadAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            spriteNode.run(deadAnimation)
        }
    }
    
    func getDamage(scene: BattleScene) {
        inputSpell = ""
        spellLabelNode.text = inputSpell
        spellLabelNodeBackground.size.width = 0
        
        if !isInvincible {
            currentHealth -= 10
            
            if currentHealth <= 0 {
                scene.stopBattle()
                scene.enemy.spriteNode.removeAllActions()
                spriteNode.removeAllActions()
                
                status = .dead
                
                AudioManager.shared.stopBgm()
                AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .playerDie)
                animateSprite()
                
                scene.goToStartScene()
            } else {
                status = .hurt
                animateSprite()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.status = .idle
                    self.animateSprite()
                }
                
                isInvincible = true
                
                invincibleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    self.spriteNode.alpha = self.spriteNode.alpha == 1.0 ? 0.5 : 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isInvincible = false
                    self.spriteNode.alpha = 1.0
                    
                    self.invincibleTimer?.invalidate()
                    self.invincibleTimer = nil
                }
            }
        }
    }
    
    // Battle scene functions
    func castSpellInBattleScene(scene: BattleSceneProtocol, chant: String, enemy: Enemy) {
        var spellToCast: Spell?
        
        for spell in spells {
            if spell.chant == chant {
                spellToCast = spell
                break
            }
        }
        
        if let spell = spellToCast {
            if !spell.isInCooldown {
                let cooldownNode = SKSpriteNode(texture: spell.cooldownTexture)
                
                // Create the mask node
                let maskNode = SKShapeNode(rectOf: CGSize(width: cooldownNode.size.width, height: cooldownNode.size.height))
                maskNode.fillColor = .black
                maskNode.strokeColor = .clear
                maskNode.yScale = 0
                
                // Create a crop node to apply the mask
                let cropNode = SKCropNode()
                cropNode.addChild(cooldownNode)
                cropNode.maskNode = maskNode
                cropNode.position = CGPoint(x: CGFloat(scene.cooldownContainer.children.count * 40), y: 0)
                
                scene.cooldownContainer.addChild(cropNode)
                
                // Position maskNode at the bottom of cropNode
                maskNode.position = CGPoint(x: 0, y: -cooldownNode.size.height / 2)
                
                // Animate the mask node to create the bottom-to-top fill effect
                let revealAction = SKAction.scaleY(to: 2.0, duration: spell.cooldownDuration)
                
                // Group the animations and run them
                maskNode.run(revealAction) {
                    cropNode.removeFromParent()
                    
                    var currentXPosition: CGFloat = 0
                    
                    for (_, node) in scene.cooldownContainer.children.enumerated() {
                        node.position = CGPoint(x: currentXPosition, y: 0)
                        currentXPosition += node.frame.width + 8  // Adjust the gap between nodes as needed
                    }
                }
                
                status = .attacking
                animateSprite()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.status = .idle
                    self.animateSprite()
                }
                
                spell.summonSpellInBattleScene(scene: scene, enemy: enemy)
            }
        } else {
            status = .stunned
            AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .stunned)
            animateSprite()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.status = .idle
                self.animateSprite()
            }
        }
    }
    
    func moveInBattleScene(scene: BattleSceneProtocol, direction: Direction) {
        if status == .moving {
            return
        }
        
        self.direction = direction
        animateSprite()
        
        let moveToCoordinate: CGPoint
        let moveAction: SKAction
        
        switch direction {
        case .left:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x - moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: moveSpeed)
            
        case .right:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x + moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: moveSpeed)
            
        case .up:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y + moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: moveSpeed)
            
        case .down:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y - moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: moveSpeed)
        }
        
        if scene.wallCoordinates.contains(moveToCoordinate) ||  !scene.floorCoordinates.contains(moveToCoordinate) {
            return
        } else {
            status = .moving
            self.direction = direction
            animateSprite()
            
            // Define the completion action to round the position
            let roundPositionAction = SKAction.run {
                self.spriteNode.position = moveToCoordinate
                self.radiusNode.position = moveToCoordinate
                
                self.status = .idle
                self.animateSprite()
            }
            
            // Create a sequence of the move actions followed by the round position action
            let sequence = SKAction.sequence([moveAction, roundPositionAction])
            
            // Run the sequences on the sprite node and the radius
            spriteNode.run(sequence)
        }
    }
    
    // Exploration Scene functions
    func interactWithObject(objects: [Object]) {
        let offset: CGPoint
        
        switch direction {
        case .left:
            offset = CGPoint(x: -32.0, y: 0.0)
        case .right:
            offset = CGPoint(x: 32.0, y: 0.0)
        case .up:
            offset = CGPoint(x: 0.0, y: 32.0)
        case .down:
            offset = CGPoint(x: 0.0, y: -32.0)
        }
        
        let interactCoordinate = CGPoint(
            x: round(spriteNode.position.x + offset.x),
            y: round(spriteNode.position.y + offset.y)
        )
        
        if let objectToInteract = objects.first(where: { $0.coordinate == interactCoordinate }) {
            objectToInteract.interact(player: self)
        }
    }
    
    func castSpellInExplorationScene(scene: ExplorationSceneProtocol, chant: String) {
        var spellToCast: Spell?
        
        for spell in spells {
            if spell.chant == chant {
                spellToCast = spell
                break
            }
        }
        
        if let spell = spellToCast {
            if !spell.isInCooldown {
                let cooldownNode = SKSpriteNode(texture: spell.cooldownTexture)
                
                // Create the mask node
                let maskNode = SKShapeNode(rectOf: CGSize(width: cooldownNode.size.width, height: cooldownNode.size.height))
                maskNode.fillColor = .black
                maskNode.strokeColor = .clear
                maskNode.yScale = 0
                
                // Create a crop node to apply the mask
                let cropNode = SKCropNode()
                cropNode.addChild(cooldownNode)
                cropNode.maskNode = maskNode
                cropNode.position = CGPoint(x: CGFloat(scene.cooldownContainer.children.count * 40), y: 0)
                scene.cooldownContainer.addChild(cropNode)
                
                // Position maskNode at the bottom of cropNode
                maskNode.position = CGPoint(x: 0, y: -cooldownNode.size.height / 2)
                
                // Animate the mask node to create the bottom-to-top fill effect
                let revealAction = SKAction.scaleY(to: 2.0, duration: spell.cooldownDuration)
                
                // Group the animations and run them
                maskNode.run(revealAction) {
                    cropNode.removeFromParent()
                    
                    var currentXPosition: CGFloat = 0
                    
                    for (_, node) in scene.cooldownContainer.children.enumerated() {
                        node.position = CGPoint(x: currentXPosition, y: 0)
                        currentXPosition += node.frame.width + 8
                    }
                }
                
                status = .attacking
                animateSprite()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.status = .idle
                    self.animateSprite()
                }
                
                spell.summonSpellInExplorationScene(scene: scene)
            }
        } else {
            status = .stunned
            AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .stunned)
            animateSprite()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.status = .idle
                self.animateSprite()
            }
        }
    }
    
    func moveInExplorationScene(scene: ExplorationSceneProtocol, direction: Direction, completion: @escaping () -> Void) {
        if status == .moving {
            return
        }
        
        self.direction = direction
        animateSprite()
        
        let moveToCoordinate: CGPoint
        let moveAction: SKAction
        
        switch direction {
        case .left:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x - moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: moveSpeed)
            
        case .right:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x + moveAmount), y: round(spriteNode.position.y))
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: moveSpeed)
            
        case .up:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y + moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: moveSpeed)
            
        case .down:
            moveToCoordinate = CGPoint(x: round(spriteNode.position.x), y: round(spriteNode.position.y - moveAmount))
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: moveSpeed)
        }
        
        if scene.wallCoordinates.contains(moveToCoordinate) || scene.objectCoordinates.contains(moveToCoordinate) || !scene.floorCoordinates.contains(moveToCoordinate) {
            return
        } else {
            status = .moving
            self.direction = direction
            animateSprite()
            
            // Define the completion action to round the position
            let roundPositionAction = SKAction.run {
                self.spriteNode.position = moveToCoordinate
                self.radiusNode.position = moveToCoordinate
                
                self.status = .idle
                self.animateSprite()
                
                completion()
            }
            
            // Create a sequence of the move actions followed by the round position action
            let sequence = SKAction.sequence([moveAction, roundPositionAction])
            
            // Run the sequences on the sprite node and the radius
            spriteNode.run(sequence)
        }
    }
}
