//
//  FeedTableViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 2/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

fileprivate let pollCellIdentifier = "PollCell"

class FeedTableViewController: UITableViewController {
  
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
    self.revealViewController().revealToggle(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController!.navigationBar.isTranslucent = false
    navigationController!.navigationBar.backgroundColor = UIColor.white
    navigationController!.navigationBar.tintColor = RMColor.AppColor
    navigationController!.navigationBar.barTintColor = UIColor.white//RMColor.AppColor
    navigationController!.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.AppColor]
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    tableView.register(UINib.init(nibName: "PollTableViewCell", bundle: nil), forCellReuseIdentifier: pollCellIdentifier)
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    print(Campus.shared.fraternitiesDict["Chi Phi"]!.posts)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 3
  }
  
  
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: pollCellIdentifier, for: indexPath) as? PollTableViewCell {
     return cell
    }
    else {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: pollCellIdentifier) as! PollTableViewCell
      return cell
    }
    
   
   // Configure the cell...
   
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
