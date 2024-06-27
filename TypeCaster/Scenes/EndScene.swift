import SpriteKit

class EndScene: SKScene {
    override func didMove(to view: SKView) {
        guard let instructionLabel = childNode(withName: "instruction") as? SKLabelNode else {
            return
        }
        
        let setAlphaToZero = SKAction.run { instructionLabel.alpha = 0.0 }
        let setAlphaToOne = SKAction.run { instructionLabel.alpha = 1.0 }
        let waitAction1 = SKAction.wait(forDuration: 0.75)
        let waitAction2 = SKAction.wait(forDuration: 0.75)
        
        let sequence = SKAction.sequence([setAlphaToOne, waitAction1, setAlphaToZero, waitAction2])
        let repeatForever = SKAction.repeatForever(sequence)
        
        instructionLabel.run(repeatForever)
    }
    
    
    override func keyDown(with event: NSEvent) {
        if let scene = SKScene(fileNamed: "StartScene") {
            if let view = self.view {
                scene.scaleMode = .aspectFill

                let transition = SKTransition.fade(withDuration: 1.0)
                view.presentScene(scene, transition: transition)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {}
}
