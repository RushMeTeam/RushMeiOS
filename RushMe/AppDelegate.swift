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
class AppDelegate: UIResponder, UIApplicationDelegate {
  var scrollPageVC : RMViewController!
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window!.layer.masksToBounds = true
    window!.layer.cornerRadius = 5
    
    if ProcessInfo.processInfo.arguments.contains("TESTING") {
     UserDefaults.standard.set(["Chi Phi", "Delta Tau Delta", "Alpha Epsilon Phi"], forKey: "Favorites") 
    }
    
    // Override point for customization after application launch.
    let swRevealVC = UIStoryboard.main.instantiateViewController(withIdentifier: "swRevealVC") as! SWViewController
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UINavigationBar.appearance().tintColor]
    self.window!.rootViewController = swRevealVC
    self.window!.makeKeyAndVisible()


    DispatchQueue.global(qos: .userInitiated).async {
      if Privacy.preferencesNeedUpdating {
        DispatchQueue.main.async {
          swRevealVC.present(UIStoryboard(name: "FirstEntry", bundle: nil).instantiateViewController(withIdentifier: "FirstVC") , animated: true, completion: {
            Privacy.lastPolicyInteractionDate = Date()
          })
        }
      }
    }
    Campus.shared.pullFromBackend()
   
    return true
  }
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//    let task = application.beginBackgroundTask(withName: "Upload User Info") { 
//      print("Doing background task")
//    } 
//    SQLHandler.inform(action: .AppWillEnterBackground)
//    application.endBackgroundTask(task)
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Backend.inform(action: .AppWillEnterBackground)

  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //SQLHandler.shared.informAction(action: .AppEnteredForeground)
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
    scrollPageVC?.navigationController?.popToRootViewController(animated: true)
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
}

extension UIStoryboard {
  static var main : UIStoryboard {
    get {
      return UIStoryboard.init(name: "Main", bundle: nil) 
    }
  }
}

