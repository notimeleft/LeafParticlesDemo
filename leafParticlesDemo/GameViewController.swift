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
    
    @IBOutlet weak var xData: UILabel!
    
    @IBOutlet weak var yData: UILabel!
    
    @IBOutlet weak var zData: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMotionManager()
        //very funny...Spritekit's coordinate system is totally screwy. The x axis starts at -view.frame.width/ 2, and ends at view.frame.width/2.
//        let totalNodes = 1000
//        let ratio = (view.frame.width + view.frame.height) / (view.frame.width)
        
        
        for _ in 1...150 {
            leafPositions.append(CGPoint(x: CGFloat.random(in: -self.view.frame.width / 2.0 ... self.view.frame.width/2.0), y: CGFloat.random(in: -self.view.frame.height / 2.0...self.view.frame.height / 2.0)))
        }
        
        for _ in 1...350 {
            dummyLeafPositions.append(CGPoint(x: CGFloat.random(in: -self.view.frame.width / 2.0 ... self.view.frame.width/2.0), y: CGFloat.random(in: -self.view.frame.height / 2.0...self.view.frame.height / 2.0)))
        }
        
        if let view = self.view as! SKView? {
            if let scene = GameScene(fileNamed: "GameScene") {
            
                gameScene = scene
                //all-important scale mode. Aspect fill will actually make the game scene longer than the view, screwing up the borders of the physics world.
                scene.scaleMode = .resizeFill
                scene.leafPositions = leafPositions
                scene.dummyLeafPositions = dummyLeafPositions
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        gameScene?.motionData = motion
    }

    
    func setupMotionManager(){
        
        if motion.isDeviceMotionAvailable {
            //motion.deviceMotionUpdateInterval = 1/10.0
            //motion.showsDeviceMovementDisplay = true
            motion.startAccelerometerUpdates()
            //motion.startDeviceMotionUpdates()
//            motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { motionData, error -> Void in
//                if let validData = motionData {
////                    self.xData.text = "\(validData.gravity.x)"
////                    self.yData.text = "\(validData.gravity.y)"
////                    self.zData.text = "\(validData.gravity.z)"
//                    self.gameScene?.xData = validData.userAcceleration.x
//                    self.gameScene?.yData = validData.userAcceleration.y
//                    self.gameScene?.zData = validData.userAcceleration.z
//                    self.xData.text = String(format: "x: %0.3f",validData.userAcceleration.x * 100)
//                    self.yData.text = String(format: "y: %0.3f",validData.userAcceleration.y * 100)
//                    self.zData.text = String(format: "z: %0.3f",validData.userAcceleration.z * 100)
//                }
//            })
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
