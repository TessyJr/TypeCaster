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
    
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, enemyType: String) -> Enemy? {
        switch enemyType {
        case "devil":
            return Devil(spriteNode: spriteNode, coordinate: coordinate)
        case "kraken":
            return Kraken(spriteNode: spriteNode, coordinate: coordinate)
        case "boss":
            return Boss(spriteNode: spriteNode, coordinate: coordinate)
        case "training-dummy":
            return TrainingDummy(spriteNode: spriteNode, coordinate: coordinate)
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
