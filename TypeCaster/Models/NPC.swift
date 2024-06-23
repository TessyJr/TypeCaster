import SpriteKit

class NPC {
    var spriteNode: SKSpriteNode = SKSpriteNode()

    var coordinate: CGPoint = CGPoint()
    var npcType: String = ""
    var status: Status = .idle
    
    var dialogIndex: Int = 0
    var dialogs: [String] = []
    
    static func create(spriteNode: SKSpriteNode, coordinate: CGPoint, npcType: String) -> NPC? {
        switch npcType {
        case "npc1":
            return NPC1(spriteNode: spriteNode, coordinate: coordinate, npcType: npcType)
        default:
            return nil
        }
    }
    
    func interact() {}
    
    func animateSprite() {
        var textures: [SKTexture] = []
        
        switch status {
        case .idle:
            for i in 1...2 {
                let textureName = "\(npcType)-idle-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let idleAnimation = SKAction.animate(with: textures, timePerFrame: 0.25)
            let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
            
            spriteNode.run(repeatIdleAnimation)
        case .talking:
            for i in 1...2 {
                let textureName = "\(npcType)-talking-\(i)"
                let texture = SKTexture(imageNamed: textureName)
                textures.append(texture)
            }
            
            let talkingAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            let repeatTalkingAnimation = SKAction.repeat(talkingAnimation, count: 2)
            
            let talkingFinishAction = SKAction.run {
                self.status = .idle
                self.animateSprite()
            }
            
            let talkingSequence = SKAction.sequence([repeatTalkingAnimation, talkingFinishAction])
            spriteNode.run(talkingSequence)
        default:
            break
        }
    }
}

class NPC1: NPC {
    init(spriteNode: SKSpriteNode, coordinate: CGPoint, npcType: String) {
        super.init()
                
        self.spriteNode = spriteNode
        self.coordinate = coordinate
        self.npcType = npcType
        
        self.dialogs = [
            "Hi there!",
            "Blah blah blah",
            "Bwek"
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
