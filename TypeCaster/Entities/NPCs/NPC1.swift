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
            "Try using one to break the boxes over there!",
            "Then you could practice with the training dummy!",
            "Well then, good luck newbie!",
        ]
    }
    
    override func interact() {
        let dialogLabelNode = spriteNode.childNode(withName: "labelNPCDialog") as! SKLabelNode
        let dialogLabelNodeBackground = spriteNode.childNode(withName: "labelNPCDialogBackground") as! SKSpriteNode
        
        if dialogIndex > -1 {
            status = .talking
            animateSprite()
            dialogLabelNode.text = dialogs[dialogIndex]
        } else {
            dialogLabelNode.text = ""
        }
        dialogLabelNodeBackground.size.width = dialogLabelNode.frame.width + 2
        
        if dialogIndex < dialogs.count - 1 {
            dialogIndex += 1
        } else {
            dialogIndex = -1
        }
    }
}

