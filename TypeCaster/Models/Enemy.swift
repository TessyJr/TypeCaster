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
    
    func animateMapSprite() {}
    
    func animateSprite() {}
    
    func getHurt(scene: BattleSceneProtocol, damage: Int) {}
    
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
        AudioManager.shared.playEnemyStateSfx(node: keyNode, enemyState: .dropKey)
        
        keyNode.run(sequence)
    }
}
