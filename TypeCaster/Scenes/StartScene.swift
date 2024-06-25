import SpriteKit

class StartScene: SKScene {
    override func didMove(to view: SKView) {
        guard let startScene = childNode(withName: "start-scene") as? SKSpriteNode else {
            return
        }
        
        let texture1 = SKTexture(imageNamed: "start-scene-1")
        let texture2 = SKTexture(imageNamed: "start-scene-2")
        
        let changeToTexture1 = SKAction.setTexture(texture1)
        let changeToTexture2 = SKAction.setTexture(texture2)
        let wait = SKAction.wait(forDuration: 0.4)
        
        let sequence = SKAction.sequence([changeToTexture1, wait, changeToTexture2, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        startScene.run(repeatForever)
    }

    
    override func keyDown(with event: NSEvent) {
        if let nextScene = SKScene(fileNamed: "ExplorationScene1") as? ExplorationSceneProtocol {
            if let view = self.view {
                let transition = SKTransition.fade(withDuration: 1.0)
                view.presentScene(nextScene, transition: transition)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {}
}
