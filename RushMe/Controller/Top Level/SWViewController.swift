//
//  SWViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 7/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class SWViewController: SWRevealViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let splitVC = UIStoryboard.main.instantiateViewController(withIdentifier: "splitVC")
    let scrollPageVC = splitVC.children.first!.children.first as! RMViewController
    let drawerMenuVC = UIStoryboard.main.instantiateViewController(withIdentifier: "drawerVC") as! DrawerMenuViewController
    self.delegate = scrollPageVC
    if (!Frontend.colors.SlideOutMenuShadowIsEnabled) {
      self.frontViewShadowOpacity = 0
    }
    else {
      self.frontViewShadowOpacity = 0.5
      self.frontViewShadowRadius = 8
    }
    self.rearViewRevealOverdraw = 0
    self.rearViewRevealDisplacement = 0
    self.rearViewRevealWidth = drawerMenuVC.preferredContentSize.width
    self.setFront(splitVC, animated: false)
    self.setRear(drawerMenuVC, animated: false)
    self.frontViewController.view.addGestureRecognizer(self.panGestureRecognizer())
    self.frontViewController.view.addGestureRecognizer(self.tapGestureRecognizer())
    _ = drawerMenuVC.setupScrollView
    _ = scrollPageVC.setupScrollView
    Campus.shared.percentageCompletionObservable.addObserver(forOwner: scrollPageVC, handler: scrollPageVC.handlePercentageCompletion(oldValue:newValue:))
    drawerMenuVC.scrollView.delegate = scrollPageVC

    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
