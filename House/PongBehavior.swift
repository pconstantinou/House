//
//  PongBehavior.swift
//  House
//
//  Created by Philip Constantinou on 5/22/15.
//  Copyright (c) 2015 Philip Constantinou. All rights reserved.
//

import UIKit

class PongBehavior: UIDynamicBehavior {
    
    var bricks = [String:UIView]()
    var counter = 0
    
    let collision = UICollisionBehavior();
    
    let partBehavior =  UIDynamicItemBehavior()

    
    struct PathNames {
        static let Wall = "Wall"
        static let Baseline = "Baseline"
        static let Paddle = "Paddle"
    }


    override init() {
        super.init()
        collision.translatesReferenceBoundsIntoBoundary = false
        
        partBehavior.allowsRotation = true
        partBehavior.elasticity = 1.1

        addChildBehavior(collision)
        addChildBehavior(partBehavior)
    }
    
    
    func addBall(ball:UIView) {
        collision.addItem(ball)
        partBehavior.addItem(ball)
        setBallVelocity(ball)
    }
    
    
    func removeBrick(brickIdentifier:String) {
        print("Attempt to remove brick \(brickIdentifier)\n")
        if let brick = bricks[brickIdentifier] {
            brick.removeFromSuperview()
            collision.removeBoundaryWithIdentifier(brickIdentifier)
            bricks[brickIdentifier] = nil
        }
    }
    
    func addBrick(brick:UIView) {
        dynamicAnimator?.referenceView?.addSubview(brick)
        let id = "Brick-\(counter)"
        bricks[id] = brick
        counter++
        collision.addBoundaryWithIdentifier(id, forPath: UIBezierPath(rect: brick.frame))
    }
        
    func setBallVelocity(ball: UIView) {
        let push = UIPushBehavior(items: [ball], mode:UIPushBehaviorMode.Instantaneous)
        push.pushDirection = CGVector(dx: 0.0, dy: -1.0)
        dynamicAnimator?.addBehavior(push)
        push.addItem(ball)
        push.action = {
            dynamicAnimator?.removeBehavior(push)
        }
    }
    
    func updatePaddle(paddle: UIView) {
        collision.removeBoundaryWithIdentifier(PathNames.Paddle)
        collision.addBoundaryWithIdentifier(PathNames.Paddle, forPath: UIBezierPath(rect: paddle.frame))
    }
    
    func setWall(wall: UIBezierPath) {
        collision.removeBoundaryWithIdentifier(PathNames.Wall)
        collision.addBoundaryWithIdentifier(PathNames.Wall, forPath: wall)
    }
    
    func setBaseline(baseline: UIBezierPath) {
        collision.removeBoundaryWithIdentifier(PathNames.Baseline)
        collision.addBoundaryWithIdentifier(PathNames.Baseline, forPath: baseline)
    }

}
