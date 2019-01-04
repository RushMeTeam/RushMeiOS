////
//  AppDelegate.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var scrollPageVC : RMViewController!
  var window: UIWindow?
  
  let notificationDelegate = Notifications()
  
  func setupTestingEnvironment() {    
    UserDefaults.standard.set(["Chi Phi", "Delta Tau Delta", 
                               "Alpha Epsilon Phi"], forKey: "Favorites") 
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Set up Notification handling
    let center = UNUserNotificationCenter.current()
    center.delegate = notificationDelegate
    
    // Set up the window and UI hierarchy
    window = UIWindow(frame: UIScreen.main.bounds)
    let swRevealVC = 
      UIStoryboard.main.instantiateViewController(withIdentifier: "swRevealVC") as! SWViewController
    
    UINavigationBar.appearance().tintColor = Frontend.colors.NavigationBarTintColor
    UINavigationBar.appearance().titleTextAttributes = 
      [NSAttributedString.Key.foregroundColor : UINavigationBar.appearance().tintColor]
    
    window!.rootViewController = swRevealVC
    window!.makeKeyAndVisible()
    
    // Require user to accept privacy preferences, if necessary.
    DispatchQueue.global(qos: .userInitiated).async {
      if Privacy.preferencesNeedUpdating {
        DispatchQueue.main.async {
          // Pull up the Privacy UI; set the most recent privacy policy interaction to now
          swRevealVC.present(UIStoryboard.privacy.instantiateViewController(withIdentifier: "FirstVC") , 
                             animated: true, 
                             completion: { Privacy.lastPolicyInteractionDate = Date() } )
        }
      }
    }
    
    // Begin loading content
    Campus.shared.pullFromBackend()
    Backend.log(action: .AppEnteredForeground)
    return true
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    Backend.log(action: .AppWillEnterBackground)
  }
  func applicationDidBecomeActive(_ application: UIApplication) {}
  func applicationWillTerminate(_ application: UIApplication) {}
  
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    //    completionHandler(shouldPerformActionFor(shortcutItem: shortcutItem))
    let shortcutType = shortcutItem.type
    guard let shortcutIdentifier = ShortCutIdentifier(identifier: shortcutType) else {
      print("Could not initialize shortcutIdentifier!")
      completionHandler(false)
      return
    }
    // Get out of detail view if necessary
    scrollPageVC?.navigationController?.popToRootViewController(animated: true)
    
    if let _ = scrollPageVC, scrollPageVC.isViewLoaded {
      switch shortcutIdentifier {
      case .Fraternities: scrollPageVC?.goToPage(page: 1, animated: false)
      case .Maps:         scrollPageVC?.goToPage(page: 0, animated: false)
      case .Calendar:     scrollPageVC?.goToPage(page: 2, animated: false)
      }
    } else {
      switch shortcutIdentifier {
      case .Fraternities: ScrollPageViewController.startingPageIndex = 1
      case .Maps:         ScrollPageViewController.startingPageIndex = 0
      case .Calendar:     ScrollPageViewController.startingPageIndex = 2
      }
    }
    completionHandler(true)
  }
}



