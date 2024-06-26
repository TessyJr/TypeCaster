import SpriteKit

class Boxes: Object {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint) {
        super.init()
        
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        
        self.isDestructible = true
    }
    
    override func interact(scene: ExplorationSceneProtocol) {
        scene.player.spellLabelNode.text = "I think I can break these rocks with a spell"
        scene.player.spellLabelNodeBackground.size.width = scene.player.spellLabelNode.frame.width + 2
    }
}
