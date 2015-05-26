//
//  DropItViewController.swift
//  House
//
//  Created by Philip Constantinou on 5/22/15.
//  Copyright (c) 2015 Philip Constantinou. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController , UIDynamicAnimatorDelegate{
    @IBOutlet weak var gameView: BezierPathsView!

    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
        }()
    
    let dropItBehavior: DropItBehavior = DropItBehavior()
    

    var attachment: UIAttachmentBehavior? {
        willSet {
            
            animator.removeBehavior(attachment)
            gameView.setPath(nil, named: PathNames.AttachmentPathName)
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment)
                attachment?.action = { [unowned self] in  
                    if let attach = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attach.center)
                        self.gameView.setPath(path, named: PathNames.AttachmentPathName);
                    }
                    
                }
            }
        }
    }
    
    
    var dropsPerRow = 10
    override func viewDidLoad() {
        animator.addBehavior(dropItBehavior)
    }
    
    struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let AttachmentPathName = "Attachment Path"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width  / 2 , y: gameView.bounds.midY - barrierSize.height / 2 )
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        gameView.setPath(path, named:  PathNames.MiddleBarrier)
    }
    
    var dropSize: CGSize {
        var size = (gameView.bounds.size.width / CGFloat(dropsPerRow))// * CGFloat(1 + (arc4random() % 3))

        return CGSize(width:size, height: size)
    }
    @IBAction func drop(sender: UITapGestureRecognizer) {
        print("Tapped")
        drop()
    }
    
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        switch sender.state {
        case .Began:
            if let viewToAttach = lastDroppedView {
                attachment = UIAttachmentBehavior(item: viewToAttach, attachedToAnchor: gesturePoint)
                lastDroppedView = nil
            }
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default:
                break
        }
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        print("Paused")
        removeCompletedRow()
    }
    
    var lastDroppedView: UIView?
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = UIView(frame: frame)
        lastDroppedView = dropView
        dropView.backgroundColor = UIColor.random
        
        dropItBehavior.addDrop(dropView)
        
    }
    
    
    
    func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
    
        do {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    } else {
                        rowIsComplete = false
                    }
                }
                dropFrame.origin.x += dropSize.width
            }
            if rowIsComplete {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
    }
}



private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.yellowColor()
        default: return UIColor.blackColor()
        }
    }
 }