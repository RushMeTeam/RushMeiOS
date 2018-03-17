//
//  PageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 3/14/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, 
                          UIPageViewControllerDelegate, 
                          UIPageViewControllerDataSource,
                          UIScrollViewDelegate{
  
  var pageControl : UIPageControl?
  lazy var orderedViewControllers: [UIViewController] = 
    [self.getViewController(forIdentifier: "mapVC"), self.getViewController(forIdentifier: "splitVC"), self.getViewController(forIdentifier: "calendarVC")]
  var viewControllerIdentifiers = ["mapVC", "splitVC", "calendarVC"]
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let identifier = viewController.restorationIdentifier, 
      let index = viewControllerIdentifiers.index(of: identifier),
          index > 0 else {
        return nil
    }
    return orderedViewControllers[(index-1)]
    
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let identifier = viewController.restorationIdentifier, 
      let index = viewControllerIdentifiers.index(of: identifier),
      index < viewControllerIdentifiers.count-1 else {
        return nil
    }
    return orderedViewControllers[index+1]
  }
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    pageControl!.currentPage = orderedViewControllers.index(of: pageViewController.viewControllers![0])!
  }
  
  
  func getViewController(forIdentifier identifier : String) -> UIViewController {
    return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) 
  }
  
  override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
    print("motion")
  }
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    print("stopping motion...")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    self.dataSource = self
    self.delegate = self
    setViewControllers([orderedViewControllers[1]], direction: .forward, 
                       animated: true, 
                       completion: nil)
    pageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.maxY - 48, width: UIScreen.main.bounds.width, height: 48))
    pageControl!.numberOfPages = orderedViewControllers.count
    pageControl!.currentPage = 1
    pageControl!.tintColor = .black
    pageControl!.pageIndicatorTintColor = RMColor.AppColor
    pageControl!.currentPageIndicatorTintColor = UIColor.white
    view.addSubview(pageControl!)
    
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
