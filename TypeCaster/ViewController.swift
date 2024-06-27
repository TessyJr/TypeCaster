import Cocoa
import SpriteKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = NSApplication.shared.windows.first
        window?.toggleFullScreen(nil)

        if let view = self.skView {
            if let scene = SKScene(fileNamed: "StartScene") {
                scene.scaleMode = .aspectFill
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

