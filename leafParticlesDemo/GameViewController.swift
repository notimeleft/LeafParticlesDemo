//
//  GameViewController.swift
//  leafParticlesDemo
//
//  Created by Jerry Wang on 12/13/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion

class GameViewController: UIViewController {

    var leafPositions = [CGPoint]()
    var dummyLeafPositions = [CGPoint]()
    
    var gameScene: GameScene?
    
    var motion = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMotionManager()
        //very funny...Spritekit's coordinate system is totally screwy. The x axis starts at -view.frame.width/ 2, and ends at view.frame.width/2.
        
        //setup 'real' leaves affected by gravity and collisions
        for _ in 1...150 {
            leafPositions.append(CGPoint(x: CGFloat.random(in: -self.view.frame.width / 2.0 ... self.view.frame.width/2.0), y: CGFloat.random(in: -self.view.frame.height / 2.0...self.view.frame.height / 2.0)))
        }
        //setup 'dummy' leaves only affected by gravity
        for _ in 1...350 {
            dummyLeafPositions.append(CGPoint(x: CGFloat.random(in: -self.view.frame.width / 2.0 ... self.view.frame.width/2.0), y: CGFloat.random(in: -self.view.frame.height / 2.0...self.view.frame.height / 2.0)))
        }
        //setup SKView, setup SKScene. Display scene content within view.
        if let view = self.view as! SKView? {
            if let scene = GameScene(leafPositions: leafPositions, dummyLeafPositions: dummyLeafPositions, motionData: motion) {
                gameScene = scene
                //all-important scale mode. Aspect fill will actually make the game scene longer than the view, screwing up the borders of the physics world.
                scene.scaleMode = .resizeFill
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    
    func setupMotionManager(){
        if motion.isDeviceMotionAvailable {
            motion.startAccelerometerUpdates()
        }
    }
    
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            gameScene?.gravity(enabled: true)
        }
    }
    
    
    @IBAction func fallButtonPushed(_ sender: Any) {
        gameScene?.gravity(enabled: true)
    }
    
    @IBAction func newLeavesPushed(_ sender: Any) {
        gameScene?.cleanUpLeaves()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
