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
    
    var isShielded: Bool = false
    
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
            let repeatStunnedAnimation = SKAction.repeat(stunnedAnimation, count: 5)
            
            let stunnedFinishAction = SKAction.run {
                self.status = .idle
                self.animateSprite()
            }
            
            let stunnedSequence = SKAction.sequence([repeatStunnedAnimation, stunnedFinishAction])
            spriteNode.run(stunnedSequence)
        case .hurt:
            for i in 1...2 {
                let textureName = "player-hurt-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let hurtAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            let repeatHurtAnimation = SKAction.repeat(hurtAnimation, count: 2)
            
            let hurtFinishAction = SKAction.run {
                self.status = .idle
                self.animateSprite()
            }
            
            let hurtSequence = SKAction.sequence([repeatHurtAnimation, hurtFinishAction])
            spriteNode.run(hurtSequence)
        case .dead:
            for i in 1...7 {
                let textureName = "player-dead-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let deadAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            spriteNode.run(deadAnimation)
        default:
            break
        }
    }
    
    func getDamage(scene: BattleScene) {
        if isInvincible {
            return
        } else if isShielded {
            isShielded = false
            if let shieldNode =  spriteNode.childNode(withName: "shield") {
                shieldNode.removeAllActions()
                shieldNode.removeFromParent()
                
                isInvincible = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isInvincible = false
                    
                    self.invincibleTimer?.invalidate()
                    self.invincibleTimer = nil
                }
            }
        } else {
            inputSpell = ""
            spellLabelNode.text = inputSpell
            spellLabelNodeBackground.size.width = 0
            
            AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .playerHit)
            
            currentHealth -= 10
            
            if currentHealth <= 0 {
                scene.stopBattle()
                scene.enemy.spriteNode.removeAllActions()
                spriteNode.removeAllActions()
                
                status = .dead
                animateSprite()
                
                AudioManager.shared.stopBgm()
                AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .playerDie)
                animateSprite()
                
                scene.goToStartScene()
            } else {
                status = .hurt
                animateSprite()
                
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
                if let cooldownNode = scene.spellCooldownNodes.first(where: { $0.texture == spell.cooldownTexture }) {
                    let overlayNode = SKSpriteNode(color: .black, size: cooldownNode.size)
                    overlayNode.alpha = 0.8
                    overlayNode.zPosition = 5
                    overlayNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                    overlayNode.position = CGPoint(x: 0, y: -cooldownNode.size.height / 2)
                    
                    cooldownNode.addChild(overlayNode)
                    
                    let scaleAction = SKAction.scaleY(to: 0.0, duration: spell.cooldownDuration)
                    
                    let removeAction = SKAction.run {
                        overlayNode.removeFromParent()
                    }
                    
                    let sequence = SKAction.sequence([scaleAction, removeAction])
                    
                    overlayNode.run(sequence)
                }
                
                status = .attacking
                animateSprite()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.status = .idle
                    self.animateSprite()
                }
                
                if spell.spellType == .shield {
                    spell.summonShield(player: self)
                } else {
                    spell.summonSpellInBattleScene(scene: scene, enemy: enemy)
                }
            }
        } else {
            status = .stunned
            AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .stunned)
            animateSprite()
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
    func interactWith(scene: ExplorationSceneProtocol) {
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
        
        if let objectToInteract = scene.objects.first(where: { $0.coordinate == interactCoordinate }) {
            objectToInteract.interact(scene: scene)
        } else if let npcToInteract = scene.npcs.first(where: { $0.coordinate == interactCoordinate }) {
            npcToInteract.interact()
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
                if let cooldownNode = scene.spellCooldownNodes.first(where: { $0.texture == spell.cooldownTexture }) {
                    let overlayNode = SKSpriteNode(color: .black, size: cooldownNode.size)
                    overlayNode.alpha = 0.8
                    overlayNode.zPosition = 5
                    overlayNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                    overlayNode.position = CGPoint(x: 0, y: -cooldownNode.size.height / 2)
                    
                    cooldownNode.addChild(overlayNode)
                    
                    let scaleAction = SKAction.scaleY(to: 0.0, duration: spell.cooldownDuration)
                    
                    let removeAction = SKAction.run {
                        overlayNode.removeFromParent()
                    }
                    
                    let sequence = SKAction.sequence([scaleAction, removeAction])
                    
                    overlayNode.run(sequence)
                }
                
                status = .attacking
                animateSprite()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.status = .idle
                    self.animateSprite()
                }
                
                if spell.spellType == .shield {
                    spell.summonShield(player: self)
                } else {
                    spell.summonSpellInExplorationScene(scene: scene)
                }
            }
        } else {
            status = .stunned
            AudioManager.shared.playPlayerStateSfx(node: self.spriteNode, playerState: .stunned)
            animateSprite()
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
        
        if scene.wallCoordinates.contains(moveToCoordinate) || scene.objectCoordinates.contains(moveToCoordinate) ||  scene.npcCoordinates.contains(moveToCoordinate) || !scene.floorCoordinates.contains(moveToCoordinate) {
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
