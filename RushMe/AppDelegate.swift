////
//  AppDelegate.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
enum ShortCutIdentifier : String {
  case Fraternities
  case Maps
  case Calendar
  init?(identifier : String) {
    if let id = identifier.components(separatedBy: ".").last {
      self.init(rawValue: id)
    }
    else {
      return nil 
    }
  }
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
  var scrollPageVC : ScrollPageViewController!
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    // Create the window
    //    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor myColor];
    UIApplication.shared.keyWindow?.backgroundColor = .white
    
    //  self.window = UIWindow(frame: UIScreen.main.bounds)
    //    self.window!.backgroundColor = UIColor.white
    //    
    ////    // Instantiate from storyboard
    //    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    //    let splitVC = mainStoryBoard.instantiateViewController(withIdentifier: "splitVC") as! UISplitViewController
    ////  let masterVC = mainStoryBoard.instantiateViewController(withIdentifier: "masterVC") as! MasterViewController
    ////    let masterNav = UINavigationController(rootViewController: masterVC)
    ////    let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
    ////    let detailNav = UINavigationController(rootViewController: detailVC)
    ////    // Add Master and Detail to the SplitView
    ////    splitVC.viewControllers = [masterNav, detailNav]
    ////
    ////    // Override point for customization after application launch.
    ////    let navController = splitVC.viewControllers[splitVC.viewControllers.count-1] as! UINavigationController
    ////    navController.topViewController!.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem
    ////    splitVC.delegate = self
    ////
    //    // SWRevealViewController
    //    let navDrawerView = mainStoryBoard.instantiateViewController(withIdentifier: "menuDrawerViewController")
    //    let swRevealView = mainStoryBoard.instantiateViewController(withIdentifier: "SWRevealVC") as! SWRevealViewController
    //    swRevealView.setFront(splitVC, animated: true)
    //    swRevealView.setRear(navDrawerView, animated: true)
    //
    //    
    //    // Set Root view and make it visible
    //    self.window!.rootViewController = swRevealView
    //    self.window!.makeKeyAndVisible()
    //    // Remove the default shadow to keep with the simplistic theme
    //    
    //    
    Campus.shared.pullFratsFromSQLDatabase()
    self.window = UIWindow(frame: UIScreen.main.bounds)
    if #available(iOS 11, *) {
      window!.layer.masksToBounds = true
      window!.layer.cornerRadius = 5
      window!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    self.scrollPageVC = mainStoryboard.instantiateViewController(withIdentifier: "scrollVC") as! ScrollPageViewController
    let scrollPageVCNav = UINavigationController.init(rootViewController: scrollPageVC)
    let swRevealVC = mainStoryboard.instantiateViewController(withIdentifier: "swRevealVC") as! SWRevealViewController
    let drawerMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "drawerVC") as! DrawerMenuViewController
    self.window!.rootViewController = swRevealVC
    self.window!.makeKeyAndVisible()
    swRevealVC.setFront(scrollPageVCNav, animated: false)
    swRevealVC.setRear(drawerMenuVC, animated: false)
    swRevealVC.delegate = scrollPageVC
    if (!RMColor.SlideOutMenuShadowIsEnabled) {
      swRevealVC.frontViewShadowOpacity = 0
    }
    swRevealVC.rearViewRevealOverdraw = 0
    swRevealVC.rearViewRevealWidth = 64
    drawerMenuVC.pageDelegate = scrollPageVC
    return true
  }
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    SQLHandler.shared.informAction(action: "App Entered Background")
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    SQLHandler.shared.informAction(action: "App Entered Foreground")
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    //    completionHandler(shouldPerformActionFor(shortcutItem: shortcutItem))
    let shortcutType = shortcutItem.type
    guard let shortcutIdentifier = ShortCutIdentifier(identifier: shortcutType) else {
      print("Could not initialize shortcutIdentifier!")
      completionHandler(false)
      return
    }
    switch shortcutIdentifier {
    case .Fraternities:
      if let _ = scrollPageVC, scrollPageVC.isViewLoaded {
        scrollPageVC?.goToPage(page: 1, animated: false)
      }
      else {
        ScrollPageViewController.startingPageIndex = 1
      }
    case .Maps:
      if let _ = scrollPageVC, scrollPageVC.isViewLoaded {
        scrollPageVC?.goToPage(page: 0, animated: false)
      }
      else {
        ScrollPageViewController.startingPageIndex = 0
      }
    case .Calendar:
      if let _ = scrollPageVC, scrollPageVC.isViewLoaded {
        scrollPageVC?.goToPage(page: 2, animated: false)
      }
      else {
        ScrollPageViewController.startingPageIndex = 2
      }
      
    }
    completionHandler(true)
    
    
   
  }
  
  //  private func shouldPerformActionFor(shortcutItem: UIApplicationShortcutItem) -> Bool {
  //    
  //    return true
  //  }
  
}

