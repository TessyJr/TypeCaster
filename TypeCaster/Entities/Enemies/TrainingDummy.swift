import SpriteKit

class TrainingDummy: Enemy {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.name = "training-dummy"
        self.currentHealth = 30
        self.maxHealth = 30
        self.attackInterval = 0.0
    }
    
    override func animateMapSprite() {
        var textures: [SKTexture] = []
        
        for i in 1...1 {
            let textureName = "\(name)-map-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        
        let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
        let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
        
        spriteNode.run(repeatIdleAnimation)
    }
    
    override func animateSprite() {
        spriteNode.removeAllActions()
        
        var textures: [SKTexture] = []
        
        switch status {
        case .idle:
            for i in 1...1 {
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
        default:
            break
        }
    }
    
    override func getHurt(scene: BattleSceneProtocol, damage: Int) {
        currentHealth -= damage
        
        if currentHealth <= 0 {
            spriteNode.removeAllActions()
            scene.stopBattle()
            
            status = .dead
            animateSprite()
            
            scene.goToPreviousScene(delay: 1.0)
            
            return
        }
        
        status = .hurt
        animateSprite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.status = .idle
            self.animateSprite()
        }
    }
    
    override func startAttacking(scene: BattleScene, player: Player, completion: @escaping () -> Void) {}
}

