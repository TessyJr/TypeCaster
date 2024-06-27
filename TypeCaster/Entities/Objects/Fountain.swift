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
        spriteNode.removeAllChildren()
        if isActive {
            AudioManager.shared.playPlayerStateSfx(node: scene.player.spriteNode, playerState: .healing)

            scene.player.currentHealth = scene.player.maxHealth
            
            let labelNode = SKLabelNode()
            labelNode.fontName = "Pixel Times"
            labelNode.fontSize = 12.0
            labelNode.text = "Your body feels refreshed"
            labelNode.position.y += 21.0
            labelNode.zPosition = 20
            
            let labelNodeBackground = SKSpriteNode()
            labelNodeBackground.color = .black
            labelNodeBackground.alpha = 0.8
            labelNodeBackground.size.height = 16.0
            labelNodeBackground.size.width = labelNode.frame.width + 2
            labelNodeBackground.position.y += 26.0
            labelNodeBackground.zPosition = 20
            
            spriteNode.addChild(labelNodeBackground)
            spriteNode.addChild(labelNode)
            
            let waitAction = SKAction.wait(forDuration: 2.0)
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([waitAction, fadeOutAction, removeAction])
            
            labelNode.run(sequence)
            labelNodeBackground.run(sequence)
            
            isActive = false
            animateObject()
        } else {
            let labelNode = SKLabelNode()
            labelNode.fontName = "Pixel Times"
            labelNode.fontSize = 12.0
            labelNode.text = "The fountain is empty"
            labelNode.position.y += 21.0
            labelNode.zPosition = 20
            
            let labelNodeBackground = SKSpriteNode()
            labelNodeBackground.color = .black
            labelNodeBackground.alpha = 0.8
            labelNodeBackground.size.height = 16.0
            labelNodeBackground.size.width = labelNode.frame.width + 2
            labelNodeBackground.position.y += 26.0
            labelNodeBackground.zPosition = 20
            
            spriteNode.addChild(labelNodeBackground)
            spriteNode.addChild(labelNode)
            
            let waitAction = SKAction.wait(forDuration: 2.0)
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([waitAction, fadeOutAction, removeAction])
            
            labelNode.run(sequence)
            labelNodeBackground.run(sequence)
        }
    }
}
