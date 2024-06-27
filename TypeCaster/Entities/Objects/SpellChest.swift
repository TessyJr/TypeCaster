import SpriteKit

class SpellChest: Object {
    var isOpened = false
    
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = false
    }
    
    override func interact(scene: ExplorationSceneProtocol) {
        if !isOpened {
            isOpened = true
            spriteNode.texture = SKTexture(imageNamed: "chest-open")
            
            AudioManager.shared.playChestOpenSfx(node: self.spriteNode)
            
            scene.player.spells.append(Shield())
            
            scene.setupSpells()
            
            let labelNode = SKLabelNode()
            labelNode.fontName = "Pixel Times"
            labelNode.fontSize = 12.0
            labelNode.text = "New spell added to your spell book!"
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
