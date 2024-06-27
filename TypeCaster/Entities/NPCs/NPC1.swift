import SpriteKit

class NPC1: NPC {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint, npcType: String) {
        super.init()
                
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.npcType = npcType
        
        self.dialogs = [
            "Oh?!",
            "Well, well... We have a new challenger, huh?",
            "You look kinda weak and homeless lol",
            "Either way, welcome to the Tower of Trials, newbie!",
            "I'll be generous and give you some tips.",
            "Press the [TAB] Button to open your spell book.",
            "You might want to memorize the magic spells.",
            "[TYPE] the spell then press [ENTER] to cast them!",
            "Try using one to break the boxes over there!",
            "Then you could practice with the training dummy!",
            "Well then, good luck newbie!"
        ]
    }
    
    override func interact(player: Player) {
        if dialogComplete {
            // Reset the state and prepare for a new interaction cycle
            player.isInteractingWithNPC = false
            spriteNode.removeAllChildren()
            dialogIndex = 0
            dialogComplete = false
        } else if dialogIndex == dialogs.count {
            // Mark the dialog as complete and clear the labels
            player.isInteractingWithNPC = false
            spriteNode.removeAllChildren()
            dialogComplete = true
        } else {
            // Show the next dialog
            player.isInteractingWithNPC = true
            spriteNode.removeAllChildren()
            
            let labelNode = SKLabelNode()
            labelNode.fontName = "Pixel Times"
            labelNode.fontSize = 12.0
            labelNode.text = dialogs[dialogIndex]
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
            
            status = .talking
            animateSprite()
            
            dialogIndex += 1
        }
    }
}
