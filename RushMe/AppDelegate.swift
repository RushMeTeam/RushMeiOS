//
//  AppDelegate.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import OHMySQL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    // Create the window
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window!.backgroundColor = UIColor.white
    
    // Instantiate from storyboard
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    let splitVC = mainStoryBoard.instantiateViewController(withIdentifier: "splitVC") as! UISplitViewController
    let masterVC = mainStoryBoard.instantiateViewController(withIdentifier: "masterVC") as! MasterViewController
    let masterNav = UINavigationController(rootViewController: masterVC)
    let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
    let detailNav = UINavigationController(rootViewController: detailVC)
    // Add Master and Detail to the SplitView
    splitVC.viewControllers = [masterNav, detailNav]
    
    // Override point for customization after application launch.
    let navController = splitVC.viewControllers[splitVC.viewControllers.count-1] as! UINavigationController
    navController.topViewController!.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem
    splitVC.delegate = self
    
    // SWRevealViewController
    let navDrawerView = mainStoryBoard.instantiateViewController(withIdentifier: "menuDrawerViewController")
    let swRevealView = mainStoryBoard.instantiateViewController(withIdentifier: "SWRevealVC") as! SWRevealViewController
    swRevealView.setFront(splitVC, animated: true)
    swRevealView.setRear(navDrawerView, animated: true)
    
    // Set Root view and make it visible
    self.window!.rootViewController = swRevealView
    self.window!.makeKeyAndVisible()
  
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    UINavigationBar.appearance().tintColor = RMColor.AppColor
    
    
    
    return true
  }
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  // MARK: - Split view

  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
      guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
      guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
      if topAsDetailController.selectedFraternity == nil {
          // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
          return true
      }
      return false
  }

}

