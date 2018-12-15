//
//  GameScene.swift
//  leafParticlesDemo
//
//  Created by Jerry Wang on 12/13/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
//haha...spent like an hour debugging collisions. The categories have to be a power of 2 to be unique, not just any random 32-bit Int. Doy.
struct CollisionCategory{
    static let floor = UInt32(1)
    static let leaf = UInt32(2)
    static let dummyLeaf = UInt32(4)
}

class GameScene: SKScene {
    
    
    public var leafPositions: [CGPoint]?
    public var dummyLeafPositions: [CGPoint]?
    
    private var gravityEnabled = false
    
    public var motionData: CMMotionManager?
    
    private var lastPointTouched = CGPoint(x:-5000,y:-5000)
    private var currentPointTouched = CGPoint(x:-5000,y:-5000)
    
    private var pointDifference: CGPoint {
        return CGPoint(x: self.lastPointTouched.x - currentPointTouched.x, y: lastPointTouched.y - currentPointTouched.y)
    }
    
    override func didMove(to view: SKView) {
        
//        let bottomLeft = CGPoint(x: -view.frame.width / 2.0, y: -view.frame.height / 2.0 + 20)
//        let bottomRight = CGPoint(x: view.frame.width / 2.0, y: -view.frame.height / 2.0 + 20)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionCategory.floor
        self.physicsBody?.collisionBitMask = CollisionCategory.leaf
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -0.2)
        
        makeNewLeaves()
    }
    
    func gravity(enabled: Bool){
        for child in children {
            child.physicsBody?.affectedByGravity = enabled
        }
        gravityEnabled = enabled
    }
    
    
    func makeNewLeaves(){
        let texture = SKTexture(imageNamed: "redLeaf")
        if let validPositions = leafPositions {
            
            for position in validPositions {
                
                let leaf = SKSpriteNode(texture: texture)
                //let leaf = SKSpriteNode(color: UIColor.red, size: CGSize(width: 3, height: 7))
                leaf.name = "realLeaf"
                leaf.position = position
                leaf.physicsBody = SKPhysicsBody(circleOfRadius: 4)
                
                leaf.physicsBody?.categoryBitMask = CollisionCategory.leaf
                leaf.physicsBody?.collisionBitMask = CollisionCategory.floor | CollisionCategory.leaf
                
                //leaf.physicsBody?.collisionBitMask = CollisionCategory.floor
                leaf.physicsBody?.affectedByGravity = false
                leaf.physicsBody?.restitution = 0.2
                addChild(leaf)
            }
            
        }
        
        if let validDummies = dummyLeafPositions {
            for position in validDummies {
                
                let leaf = SKSpriteNode(texture: texture)
                //let leaf = SKSpriteNode(color: UIColor.white, size: CGSize(width: 3, height: 7))
                leaf.name = "dummyLeaf"
                leaf.position = position
                leaf.physicsBody = SKPhysicsBody(circleOfRadius: 4)
                //leaf.physicsBody = SKPhysicsBody(rectangleOf: leaf.size)
                leaf.physicsBody?.categoryBitMask = CollisionCategory.dummyLeaf
                leaf.physicsBody?.collisionBitMask = CollisionCategory.floor
                leaf.physicsBody?.affectedByGravity = false
                leaf.physicsBody?.restitution = 0.0
                addChild(leaf)
            }
        }
    }
    
    func cleanUpLeaves(){
        removeAllChildren()
        makeNewLeaves()
        //hack-y solution to ensure that resetting the scene will not affect the gravity status of any leaves in the initial loading
        lastPointTouched = CGPoint(x:-5000,y:-5000)
        currentPointTouched = CGPoint(x:-5000,y:-5000)
        gravity(enabled: false)
    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPointTouched = (touches.first?.location(in: self))!
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPointTouched = (touches.first?.location(in: self))!
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(currentPointTouched.x - lastPointTouched.x, currentPointTouched.y - lastPointTouched.y)
        //currentPointTouched = CGPoint.zero
        //lastPointTouched = CGPoint.zero
    }
    
    func proximityOfTwoPoints(for distance: CGFloat, point1: CGPoint, point2: CGPoint) -> Bool{
        return abs(point1.x - point2.x) <= distance && abs(point1.y - point2.y) <= distance
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        //if gravity has been enabled, the 'wind' force must fight against it, so it has to be greater
        let gravityFactor : CGFloat = gravityEnabled ? 600 : 1000
        
        for child in children {
            //only apply the 'wind' force to a leaf that is close to the last touched point
            if proximityOfTwoPoints(for: 40.0, point1: currentPointTouched, point2: child.position) {
                //once a leaf has been affected by the wind (i.e torn off a branch), it must deal with gravity
                if !gravityEnabled {
                    child.physicsBody?.affectedByGravity = true
                }
                //we shouldn't let wind force get too large
                let xScale = -pointDifference.x/gravityFactor
                let yScale = -pointDifference.y/gravityFactor
                child.physicsBody?.applyImpulse(CGVector(dx: xScale < 50.0 ? xScale : 50.0, dy: yScale < 50.0 ? yScale : 50.0))
            }
            
        }
        
        if !gravityEnabled { return }
        //tilt screen to change the impulse force that simulates gravity. We could just change WorldPhysics' gravity, but somehow this is more efficient for the CPU. I think. 
        if let validData = motionData?.accelerometerData{
            for child in children {
                if child.physicsBody?.affectedByGravity == false {
                    return
                }
                child.physicsBody?.applyImpulse(CGVector(dx:
                    validData.acceleration.x / 150.0 , dy: validData.acceleration.y / 150.0))
            }
        }
    }
}
