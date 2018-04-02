//
//  SplitViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 3/21/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController,
                           UISplitViewControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
      self.preferredDisplayMode = .allVisible
        // Do any additional setup after loading the view.
    }
  func splitViewController(_ splitViewController: UISplitViewController, 
                           collapseSecondary secondaryViewController: UIViewController, 
                           onto primaryViewController: UIViewController) -> Bool {
    return true
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
