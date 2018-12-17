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
enum CollisionCategory: UInt32{
    case floor = 1
    case leaf = 2
    case dummyLeaf = 4
}

//define either a real leaf or a dummy leaf

class LeafType {
    let typeName: String
    let categoryBitmask: UInt32
    let collsionBitmask: UInt32
    let bounciness: CGFloat
    init(type: String){
        if type == "realLeaf" {
            self.typeName = type
            categoryBitmask = CollisionCategory.leaf.rawValue
            collsionBitmask = CollisionCategory.leaf.rawValue | CollisionCategory.floor.rawValue
            bounciness = 0.2
        } else {
            self.typeName = "dummyLeaf"
            categoryBitmask = CollisionCategory.dummyLeaf.rawValue
            collsionBitmask = CollisionCategory.floor.rawValue
            bounciness = 0.0
        }
    }
}

class GameScene: SKScene {
    
    var leafPositions: [CGPoint]?
    var dummyLeafPositions: [CGPoint]?
    var motionData: CMMotionManager?
    var leafTextures: [SKTexture]?
    
    private var gravityEnabled = false

    private var lastPointTouched = CGPoint(x:-5000,y:-5000)
    private var currentPointTouched = CGPoint(x:-5000,y:-5000)
    
    private var pointDifference: CGPoint {
        return CGPoint(x: self.lastPointTouched.x - currentPointTouched.x, y: lastPointTouched.y - currentPointTouched.y)
    }
    
    //first time convenience initializers saved my bum! It's easier to encapsulate all the details of the game scene in here, rather than trying to set everything elsewhere.
    convenience init?(leafPositions: [CGPoint], dummyLeafPositions: [CGPoint],motionData: CMMotionManager){
        self.init(fileNamed: "GameScene")
        self.leafPositions = leafPositions
        self.dummyLeafPositions = dummyLeafPositions
        self.motionData = motionData
        self.leafTextures = [
        SKTexture(imageNamed: "redLeaf"),
        SKTexture(imageNamed: "orangeLeaf"),
        SKTexture(imageNamed: "yellowLeaf"),
        ]
    }
    
    
    
    override func didMove(to view: SKView) {
        
//        let bottomLeft = CGPoint(x: -view.frame.width / 2.0, y: -view.frame.height / 2.0 + 20)
//        let bottomRight = CGPoint(x: view.frame.width / 2.0, y: -view.frame.height / 2.0 + 20)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionCategory.floor.rawValue
        self.physicsBody?.collisionBitMask = CollisionCategory.leaf.rawValue
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -0.2)
        
        makeBothLeafTypes()
    }
    
    func gravity(enabled: Bool){
        for child in children {
            child.physicsBody?.affectedByGravity = enabled
        }
        gravityEnabled = enabled
    }
    
    
    func makeBothLeafTypes(){
        let realLeaves = LeafType(type: "realLeaf")
        let dummyLeaves = LeafType(type: "dummyLeaf")
        makeNewLeaves(leafType: realLeaves, leafPositions: self.leafPositions!)
        makeNewLeaves(leafType: dummyLeaves, leafPositions: self.dummyLeafPositions!)
    }
    
    
    func makeNewLeaves(leafType: LeafType, leafPositions: [CGPoint]){
        
        for position in leafPositions {
            //randomize leaf color a bit
            let texture = leafTextures?[Int.random(in: 0...2)]
            let leaf = SKSpriteNode(texture: texture, size: CGSize(width: 6, height: 6))
            leaf.name = leafType.typeName
            leaf.position = position
            leaf.physicsBody = SKPhysicsBody(circleOfRadius: 6)
            leaf.physicsBody?.categoryBitMask = leafType.categoryBitmask
            leaf.physicsBody?.collisionBitMask = leafType.collsionBitmask
            leaf.physicsBody?.affectedByGravity = false
            leaf.physicsBody?.restitution = leafType.bounciness
            addChild(leaf)
        }
    }
    
    
    
    func cleanUpLeaves(){
        removeAllChildren()
        makeBothLeafTypes()
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
        lastPointTouched = CGPoint.zero
        currentPointTouched = CGPoint(x:-5000,y: -5000)
    }
    
    func proximityOfTwoPoints(for distance: CGFloat, point1: CGPoint, point2: CGPoint) -> Bool{
        return abs(point1.x - point2.x) <= distance && abs(point1.y - point2.y) <= distance
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        //if gravity has been enabled, the 'wind' force must fight against it, so it has to be greater
        let gravityFactor : CGFloat = gravityEnabled ? 100 : 300
        
        let accelerationData = motionData?.accelerometerData
        
        for child in children {
            //only apply the 'wind' force to a leaf that is close to the last touched point
            //hmm...maybe for larger screens, we want proximity to be greater as well. For smaller screens, 40 pts would be more than enough for our butterfingers
            if proximityOfTwoPoints(for: 40.0, point1: currentPointTouched, point2: child.position) {
                //once a leaf has been affected by the wind (i.e torn off a branch), it must deal with gravity
                if !gravityEnabled {
                    child.physicsBody?.affectedByGravity = true
                }
                //we shouldn't let wind force get too large
                let xScale = -pointDifference.x/gravityFactor
                let yScale = -pointDifference.y/gravityFactor
                child.physicsBody?.applyImpulse(CGVector(dx: xScale < 250.0 ? xScale : 250.0, dy: yScale < 250.0 ? yScale : 250.0))
            }
            
            //for those leaves that have been 'plucked', they must now be affected by the force of gravity, whether from the world gravity or from device rotation's simulated gravity
            if child.physicsBody?.affectedByGravity == true {
                if let validData = accelerationData{
                    child.physicsBody?.applyImpulse(CGVector(dx:
                        validData.acceleration.x / 150.0 , dy: validData.acceleration.y / 150.0))
                }
            }
            
        }
    }
}
