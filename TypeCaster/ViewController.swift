import Cocoa
import SpriteKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = NSApplication.shared.windows.first
        window?.toggleFullScreen(nil)

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "ExplorationScene1") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

