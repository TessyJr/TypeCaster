import SpriteKit

class Candles: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = true
        
        self.animateObject()
    }
    
    override func animateObject() {
        for i in 1...2 {
            let textureName = "candles-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        
        let activeAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
        let repeatedActiveAnimation = SKAction.repeatForever(activeAnimation)
        
        spriteNode.run(repeatedActiveAnimation)
    }
}
