//
//  ConversationListViewControllerTableViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/14/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import Firebase
import Messages
fileprivate let conversationCellReuseIdentifier = "conversationCellRID"
class ConversationListViewControllerTableViewController: UITableViewController {
  @IBOutlet var fratSignInButton: UIBarButtonItem!
  private var user : User? = nil
  @IBOutlet var drawerButton: UIBarButtonItem!
  override func viewDidLoad() {
    super.viewDidLoad()
    if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      drawerButton.target = self.revealViewController()
      drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
      // Allow drag to open drawer, tap out to close
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
      
    }
    fratSignInButton.isEnabled = true // SHOULD CHANGE
    Auth.auth().signInAnonymously(completion : { (user, error) in 
      if let _ = error {
        print("Anonymous login failed!")
        
        print(error!.localizedDescription) 
      }
      else {
        print("Anonymous login succeeded!")
        self.user = user
      }
    })
    //navigationController?.navigationBar.isTranslucent = false
    //navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    //navigationController?.navigationBar.tintColor = RMColor.AppColor
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return Campus.shared.favoritedFrats.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellReuseIdentifier, for: indexPath)
    cell.textLabel?.text = Campus.shared.favoritedFrats[indexPath.row]
    // Configure the cell...
    
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier, identifier == "showDetail" {
      if let senderVC = segue.destination as? ChatViewController {
        if let senderCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: senderCell) {
          let frat = Campus.shared.favoritedFrats[indexPath.row]
          print(frat)
          senderVC.set(channel: frat, user: user!)
        }
         
      }
    }
  }
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    return self.user != nil
  }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
