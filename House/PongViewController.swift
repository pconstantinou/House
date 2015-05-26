//
//  PongViewController.swift
//  House
//
//  Created by Philip Constantinou on 5/22/15.
//  Copyright (c) 2015 Philip Constantinou. All rights reserved.
//

import UIKit

class PongViewController: UIViewController, GameWatcherDelegate {

    
    @IBOutlet weak var pongView: PongUIView!
    
    var paddleView: UIView {
        return pongView.paddle
    }
    
    var bricksRemaining: Int {
        get {
            return pongView.pongBehavior.bricks.count
        }
    }
    
    var paddleCenter: CGFloat {
        get {
            return pongView.paddle.center.x
        }
        set {
            pongView.paddle.center.x = newValue
            pongView.pongBehavior.updatePaddle(paddleView)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pongView.gameWatcherDelegate = self
        pongView.finishSetup()
        pongView.initGame()
    }
    
    @IBAction func restart(sender: UITapGestureRecognizer) {
        pongView.resetBall()
    }
    
    @IBAction func movePaddle(sender: UIPanGestureRecognizer) {
        switch (sender.state) {
        case .Began, .Changed:
            paddleCenter = sender.locationInView(pongView).x
        default:
            break
        }
    }
    

    func playAgainActionHandler(action: UIAlertAction!) {
        pongView.initGame()
        pongView.resetBall()
    }

    
    
    func gameDidWin() {
        var alert = UIAlertController(
            title: "You win!",
            message: "You cleared all the blocks",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let playAgainAction = UIAlertAction(title: "Play again",
            style: UIAlertActionStyle.Default,
            handler: playAgainActionHandler)

        alert.addAction(playAgainAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func gameDidFinish() {
        var alert = UIAlertController(
            title: "Try again!",
            message: "Sorry - you lost",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let playAgainAction = UIAlertAction(title: "Play again",
            style: UIAlertActionStyle.Default,
            handler: playAgainActionHandler)
        
        alert.addAction(playAgainAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func blockDidGetHit() {
        
    }
}
