//
//  RMViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 7/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class RMViewController: ScrollPageViewController, 
                        SWRevealViewControllerDelegate, 
                        UIPageViewControllerDelegate, 
                        UISplitViewControllerDelegate {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.pageViewControllers = [UIStoryboard.main.instantiateViewController(withIdentifier: "mapVC"),
                                UIStoryboard.main.instantiateViewController(withIdentifier: "masterVC"),
                                UIStoryboard.main.instantiateViewController(withIdentifier: "calendarVC"),
                                UIStoryboard.main.instantiateViewController(withIdentifier: "settingsViewController")] 
  }
  
  override var titleImage : UIImage {
    get {
     return #imageLiteral(resourceName: "RushMeLogo") 
    }
  }
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  // MARK: Actions
  @IBAction func presentDrawer(_ sender: UIBarButtonItem? = nil) {
    self.revealViewController().revealToggle(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      revealViewController().panGestureRecognizer().isEnabled = false
    }
    (segue.destination as? UIPageViewController)?.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    revealViewController().panGestureRecognizer().isEnabled = true
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    revealViewController().panGestureRecognizer().isEnabled = false

  }
  func handlePercentageCompletion(oldValue : Float?, newValue : Float) {
    progress = newValue
    DispatchQueue.main.async {
      self.drawerButton.isEnabled = newValue == 1 || newValue == 0
    }
    for updatable in pageViewControllers where updatable is ScrollableItem {
     (updatable as! ScrollableItem).updateData()
    }
  }
  
  override func goToPage(page: Int, animated: Bool) {
    super.goToPage(page: page, animated: animated)
    (revealViewController()?.rearViewController as? ScrollButtonViewController)?.set(newCurrentPage: page)
  }
  
  // MARK: SWRevealViewControllerDelegate
  func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
    scrollView?.isUserInteractionEnabled = !(position == .right || position == .rightMost)
    scrollView?.isScrollEnabled = position == .right
    (currentViewController as? ScrollableItem)?.updateData()
  }
  // MARK: UIPageViewControllerDelegate
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, 
                          previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed, let fratName = (pageViewController.viewControllers?.first as? DetailViewController)?.selectedFraternity?.name {
      Backend.log(action: .FraternitySelected, options: fratName) 
      pageViewController.title = fratName.greekLetters
    }
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

