//
//  SWViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 7/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class SWViewController: SWRevealViewController {
  
  var splitVC : UIViewController! 
  var scrollPageVC : RMViewController!
  var drawerMenuVC : DrawerMenuViewController!

  override func viewWillAppear(_ animated: Bool) {
    splitVC = UIStoryboard.main.instantiateViewController(withIdentifier: "splitVC")
    scrollPageVC = splitVC.children.first!.children.first as? RMViewController
    drawerMenuVC = UIStoryboard.main.instantiateViewController(withIdentifier: "drawerVC") as? DrawerMenuViewController
    
    delegate = scrollPageVC
    setFront(splitVC, animated: false)
    setRear(drawerMenuVC, animated: false)
    
    frontViewShadowOpacity = Frontend.colors.SlideOutMenuShadowIsEnabled ? 0.5 : 0
    frontViewShadowRadius = Frontend.colors.SlideOutMenuShadowIsEnabled ? 8 : 0
    
    rearViewRevealOverdraw = 0
    rearViewRevealDisplacement = 0
    rearViewRevealWidth = drawerMenuVC.preferredContentSize.width
    
    frontViewController.view.addGestureRecognizer(panGestureRecognizer())
    frontViewController.view.addGestureRecognizer(tapGestureRecognizer())
    _ = drawerMenuVC.setupScrollView
    _ = scrollPageVC.setupScrollView
    drawerMenuVC.scrollView.delegate = scrollPageVC
    
    // Do any additional setup after loading the view.
    Campus.shared.percentageCompletionObservable.addObserver(forOwner: scrollPageVC, handler: scrollPageVC.handlePercentageCompletion(oldValue:newValue:))
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
