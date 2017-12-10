//
//  ChatViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/10/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import Chatto
import Firebase

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      Auth.auth().signInAnonymously(completion : { (user, error) in 
        if let _ = error {
          print("Anonymous login failed!")
         print(error!.localizedDescription) 
        }
        else {
          print("Anonymous login succeeded!")
        }
        })
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
