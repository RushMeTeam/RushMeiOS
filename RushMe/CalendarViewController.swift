//
//  CalendarViewController.swift
//  RushMe
//
//  Created by James Hines on 10/21/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let revealVC = self.revealViewController(){
            drawerButton.target = revealVC
            drawerButton.action = #selector(revealVC.revealToggle(_:))
        }
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
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
