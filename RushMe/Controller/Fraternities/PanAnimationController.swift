//
//  PanAnimationController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/4/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class PanAnimationController: NSObject, UIViewControllerAnimatedTransitioning{
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.2
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
      let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
      else {
        print("Failed Animate Transition!")
        return
    }
    let screenBounds = UIScreen.main.bounds
    toVC.view.frame = CGRect.init(origin: CGPoint.init(x: screenBounds.width, y: 0), size: toVC.view.frame.size)
    toVC.view.layer.shadowColor = UIColor.black.cgColor
    toVC.view.layer.masksToBounds = false
    toVC.view.layer.shadowRadius = 10
    toVC.view.layer.shadowOpacity = 0.2
    transitionContext.containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
    
    
    let finalFrame = CGRect(origin: CGPoint.zero, size: screenBounds.size)
    
    UIView.animate(
      withDuration: transitionDuration(using: transitionContext),
      animations: {
        fromVC.view.transform = CGAffineTransform.init(translationX: toVC.view.frame.width, y: 0)
        toVC.view.frame = finalFrame
        
    },
      completion: { _ in
        fromVC.view.transform = CGAffineTransform.identity
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    )
  }
  

}


class PanInteractionController : UIPercentDrivenInteractiveTransition {
  var interactionInProgress = false
  var shouldCompleteTransition = false
}
