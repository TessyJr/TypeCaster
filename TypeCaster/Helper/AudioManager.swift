import AVFoundation
import SpriteKit

class AudioManager {
    
    static let shared = AudioManager()
    
    private var BgmPlayer: AVAudioPlayer?
    
    private var explorationBgmIsOn = false
    private var battleBgmIsOn = false
    
    func playBgm(bgmType: BgmType) {
        switch bgmType {
        case .exploration:
            if explorationBgmIsOn {return}
            startBgm(fileName: "explorationBGM")
            explorationBgmIsOn = true
            battleBgmIsOn = false
            
        case .battle:
            if battleBgmIsOn {return}
            startBgm(fileName: "battleBGM")
            battleBgmIsOn = true
            explorationBgmIsOn = false
        }
    }
    
    private func startBgm(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {return}
        
        do {
            BgmPlayer = try AVAudioPlayer(contentsOf: url)
            BgmPlayer?.numberOfLoops = -1
            BgmPlayer?.play()
        } catch {
            print("BGM Error: \(error.localizedDescription)")
        }
    }
    
    func stopBgm() {
        BgmPlayer?.stop()
        battleBgmIsOn = false
        explorationBgmIsOn = false
    }
    
    func playSpellSfx(node: SKSpriteNode, spellType: SpellSfxType) {
        let fileName = spellType.rawValue
        let sfx = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        node.run(sfx)
    }
    
    func playPlayerStateSfx(node: SKSpriteNode, playerState: PlayerStateSfxType) {
        let fileName = playerState.rawValue
        let sfx = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        node.run(sfx)
    }
    
    func playEnemyFoundSfx(node: SKSpriteNode) {
        let sfx = SKAction.playSoundFileNamed("alert", waitForCompletion: false)
        node.run(sfx)
    }
    
    func playEnemyDropKeySfx(node: SKSpriteNode) {
        let sfx = SKAction.playSoundFileNamed("shimmeringKey", waitForCompletion: false)
        node.run(sfx)
    }
}
