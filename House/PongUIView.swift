//
//  PongUIView.swift
//  House
//
//  Created by Philip Constantinou on 5/22/15.
//  Copyright (c) 2015 Philip Constantinou. All rights reserved.
//

import UIKit

public class PongUIView: UIView, UICollisionBehaviorDelegate {

    let ball = BezierPathsView()
    
    let paddle = BezierPathsView()
    
    let pongBehavior = PongBehavior()
    
    var gameWatcherDelegate: GameWatcherDelegate?
    
    var path: UIBezierPath!
    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self)
        return lazilyCreatedDynamicAnimator
        }()

    
    var boardDimensions = BoardDimensions(rows: 3, columns: 10)
    
    
    public struct BoardDimensions {
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
        }
        let rows: Int
        let columns: Int
    }
    
    lazy var brickSize: CGSize = {
        let width = self.bounds.size.width / CGFloat(self.boardDimensions.columns)
        print("Bounds \(self.bounds)")
        let height = width
        let lazilyCreatedBrickSize = CGSize(width: width, height: height)
        print("Brick size \(lazilyCreatedBrickSize)")

        return lazilyCreatedBrickSize
    }()
    
    func initSubViews() {
        addSubview(ball)
        addSubview(paddle)
        pongBehavior.addBall(ball)
        
        pongBehavior.updatePaddle(paddle)
        pongBehavior.collision.collisionDelegate = self
    }
    
    func finishSetup() {
        ball.frame  = CGRect(origin: CGPoint(x: bounds.width/2,
            y: bounds.height - (3 * brickSize.height)),
            size: brickSize)
        resetBall()
        resetPaddle()
        let path = UIBezierPath(ovalInRect: ball.bounds)
        ball.setPath(path, named: "Ball")
        
        paddle.setPath(UIBezierPath(ovalInRect: paddle.bounds), named: "Paddle")
        paddle.backgroundColor = UIColor.whiteColor()
        
        initPongBoundaries()
        animator.addBehavior(pongBehavior)
    }
    
    
    init(frame: CGRect, boardDimensions: BoardDimensions) {
        super.init(frame: frame)
        self.boardDimensions = boardDimensions
        initSubViews()
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    
    func resetBall() {
        ball.center =  CGPoint(x: bounds.width/2,
                               y: bounds.height - (3 * brickSize.height))
        pongBehavior.setBallVelocity(ball)
        ball.backgroundColor = UIColor.whiteColor()
        animator.updateItemUsingCurrentState(ball)
        setNeedsDisplay()

    }
    
    func resetPaddle() {
        print("Reset paddle")
        paddle.frame = CGRect(origin: CGPoint(x:bounds.width / 2 ,
                                              y: bounds.height - brickSize.height - 5),
                                size: CGSize(width: brickSize.width * 4, height: brickSize.height))
        paddle.backgroundColor = UIColor.blackColor()
        animator.updateItemUsingCurrentState(paddle)
        setNeedsDisplay()
    }
    
    
    func initPongBoundaries() {
        path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: bounds.height))
        path.addLineToPoint(CGPointZero)
        path.addLineToPoint(CGPoint(x: bounds.width, y: 0))
        path.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        pongBehavior.setWall(path)
        
        let baseLine = UIBezierPath()
        baseLine.moveToPoint(CGPoint(x: 0, y: bounds.height))
        baseLine.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        pongBehavior.setBaseline(baseLine);
    }
    
    func clearBricks() {
        let bricks = pongBehavior.bricks
        for (id, brick) in bricks {
            pongBehavior.removeBrick(id)
        }
    }
    

    
    func initGame() {
        let origin = CGPoint(x: brickSize.width / 2.0, y: brickSize.height / 2.0)
        for r in 0 ..< boardDimensions.rows {
            let rOffset = brickSize.width * CGFloat(r)
            for c in 0 ..< boardDimensions.columns {
                let cOffset = brickSize.height * CGFloat(c)
                let brickCenter = CGPoint(x: cOffset, y: rOffset + (brickSize.height * 2))
                var smallerBrick = CGSize(width: brickSize.width * 0.95, height: brickSize.height * 0.95)
                let brickView = UIView(frame: CGRect(origin: brickCenter, size: smallerBrick))
                brickView.backgroundColor = UIColor.purpleColor()
                pongBehavior.addBrick(brickView)
            }
        }
    }
    
    public func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem,
        withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
            if let brickId = identifier as? String {

                if (pongBehavior.removeBrick(brickId)) {
                    gameWatcherDelegate?.blockDidGetHit()
                    if pongBehavior.bricks.count == 0 {
                        gameWatcherDelegate?.gameDidWin()
                    }
                }
                if brickId == PongBehavior.PathNames.Baseline {
                    gameWatcherDelegate?.gameDidFinish()
                    clearBricks()
                    initGame()
                }
            }
    }

    
}

public protocol GameWatcherDelegate {
    func gameDidFinish()
    func gameDidWin()
    func blockDidGetHit()
}
