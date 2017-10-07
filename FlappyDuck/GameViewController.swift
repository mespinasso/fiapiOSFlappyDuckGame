//
//  GameViewController.swift
//  FlappyDuck
//
//  Created by Usuário Convidado on 06/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

var gameWidth: CGFloat!
var gameHeight: CGFloat!

class GameViewController: UIViewController {
    
    var musicPlayer : AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stage = view as! SKView
        stage.ignoresSiblingOrder = true
        
        gameWidth = 320.0
        gameHeight = gameWidth * stage.bounds.height/stage.bounds.width
        
        let scene = GameScene(size: CGSize(width: gameWidth, height: gameHeight))
        scene.scaleMode = .aspectFill
        stage.presentScene(scene)
        
        playMusic()
    }
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "musica", withExtension: "mp3") {
            musicPlayer = try! AVAudioPlayer(contentsOf: musicURL)
            musicPlayer.numberOfLoops = -1
            musicPlayer.volume = 0.4
            musicPlayer.play()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
