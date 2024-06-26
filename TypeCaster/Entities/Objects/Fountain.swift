import SpriteKit

class Fountain: Object {
    var isActive: Bool = true
    
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = false
        
        self.animateObject()
    }
    
    override func animateObject() {
        spriteNode.removeAllActions()
        
        if isActive {
            for i in 1...3 {
                let textureName = "fountain-active-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let activeAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            let repeatedActiveAnimation = SKAction.repeatForever(activeAnimation)
            
            spriteNode.run(repeatedActiveAnimation)
        } else {
            for i in 1...4 {
                let textureName = "fountain-inactive-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let inactiveAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            spriteNode.run(inactiveAnimation)
        }
    }
    
    override func interact(scene: ExplorationSceneProtocol) {
        if isActive {
            scene.player.spellLabelNode.text = "That's refreshing!"
            scene.player.spellLabelNodeBackground.size.width = scene.player.spellLabelNode.frame.width + 2
            
            AudioManager.shared.playPlayerStateSfx(node: scene.player.spriteNode, playerState: .healing)
            scene.player.currentHealth += 20
            
            if scene.player.currentHealth > scene.player.maxHealth {
                scene.player.currentHealth = scene.player.maxHealth
            }
            
            isActive = false
            animateObject()
        } else {
            scene.player.spellLabelNode.text = "The fountain is empty"
            scene.player.spellLabelNodeBackground.size.width = scene.player.spellLabelNode.frame.width + 2
        }
    }
}
