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
  @IBOutlet var drawerButton: UIBarButtonItem!
  var anonymousUser : User?
  var signedInAsFrat : Bool {
    get {
      return UniqueUser.shared.user != nil 
    }
  }
  var isAnonymous : Bool {
    get {
      return !signedInAsFrat
    }
  }
  class Pair<T: Hashable, U: Hashable> : Hashable {
    static func ==(lhs: ConversationListViewControllerTableViewController.Pair<T, U>, 
                   rhs: ConversationListViewControllerTableViewController.Pair<T, U>) -> Bool {
      return lhs.first == rhs.first && lhs.second == rhs.second
    }
    init (_ first : T, _ second : U) {
      self.first = first
      self.second = second
    }
    let first : T
    let second : U
    var hashValue : Int {
      get {
        return first.hashValue &* 31 &+ second.hashValue
      }
    }
  }
  
  var conversations : [String] = []
  var lastMessages = [Pair<Bool, Int>:Pair<String, LGChatMessage>]() 
  var channelReferenceHandle : DatabaseHandle? = nil
  var selectedChannel : DatabaseReference? = nil
  @IBAction func signIn(_ sender: UIBarButtonItem) {
    if signedInAsFrat {
      do {
        try Auth.auth().signOut() 
      }
      catch let e {
        print(e.localizedDescription)
      }
      print("Signed Out")
      signInAnonymously()
      self.tableView.reloadData()
    }
    else {
      self.present(storyboard!.instantiateViewController(withIdentifier: "signInNavVC"), animated: true, completion: nil)
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      drawerButton.target = self.revealViewController()
      drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
      // Allow drag to open drawer, tap out to close
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
      navigationItem.rightBarButtonItem = nil
      
    }
    // TODO: ONLY APPEARS WHEN SETTING ENABLED
    fratSignInButton.isEnabled = true
    
    
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  private func signInAnonymously() {
    Auth.auth().signInAnonymously(completion : { (user, error) in 
      if let _ = error {
        print("Anonymous login failed!")
        print(error!.localizedDescription) 
      }
      else {
        print("Anonymous login succeeded!")
        self.anonymousUser = user
        UniqueUser.shared.user = nil
        self.tableView.reloadData()
        self.fratSignInButton.title = "Frat Sign In"
      }
    }) 
   
    self.fratSignInButton.title = (!self.signedInAsFrat) ? 
      "Frat Sign In" : "Sign Out"
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if UniqueUser.shared.fratSignInEnabled {
      self.navigationItem.rightBarButtonItem = self.fratSignInButton 
    }
    else {
      self.navigationItem.rightBarButtonItem = nil 
    }
    if signedInAsFrat {
      let _ = Database.database().reference().child("Chi Phi").observe(.value) { (snapshot) in
        if let conversationList = snapshot.value as? Dictionary<String, AnyObject>{
          self.conversations = []
          for conversation in conversationList.keys{
            self.conversations.append(conversation)
          }
          self.tableView.reloadData()
        }
      }
    }
    if Auth.auth().currentUser == nil {
      self.signInAnonymously()
    }
    self.tableView.reloadData()
    fratSignInButton.title = (!self.signedInAsFrat) ? 
                                              "Frat Sign In" : "Sign Out"
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
    if self.signedInAsFrat {
      return max(conversations.count, 1)
    }
    return max(Campus.shared.favoritedFrats.count, 1)
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellReuseIdentifier, for: indexPath)
    if (signedInAsFrat && conversations.count == 0) || (!signedInAsFrat && Campus.shared.favoritedFrats.count == 0){
      let cell = UITableViewCell()
      cell.textLabel!.text = "No messages (yet!)"
      cell.textLabel!.textColor = UIColor.darkGray
      cell.textLabel?.textAlignment = .center
      return cell
    }
    else if signedInAsFrat {
      cell.textLabel?.text = "User " + String(indexPath.row+1)
      cell.detailTextLabel?.text = self.conversations[indexPath.row] 
    }
    else {
      //cell.imageView?.image = Campus.shared.fraternitiesDict[Campus.shared.favoritedFrats[indexPath.row]]?.previewImage
      cell.textLabel?.text = Campus.shared.favoritedFrats[indexPath.row]
      cell.detailTextLabel?.text = "Send \(Campus.shared.favoritedFrats[indexPath.row].greekLetters) a message!"
    }
    // Configure the cell...
    if let lastMessage = self.lastMessages[Pair(self.signedInAsFrat, indexPath.row)] {
      if lastMessage.second.sentBy == .User {
        cell.detailTextLabel?.text = "You: " + lastMessage.second.content 
      }
      else {
        cell.detailTextLabel?.text = lastMessage.second.content 
      }
    }
    return cell
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
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier, identifier == "showDetail" {
      if let senderVC = segue.destination.childViewControllers.first as? ChatViewController {
        if let senderCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: senderCell) {
          if signedInAsFrat {
            self.selectedChannel = Database.database().reference().child("Chi Phi").child(conversations[indexPath.row])
            senderVC.set(title: "User " + String(indexPath.row+1), channel: self.selectedChannel!, user: Auth.auth().currentUser!)
          }
          else {
            let frat = Campus.shared.favoritedFrats[indexPath.row]
            self.selectedChannel = Database.database().reference().child(frat).child(Messaging.messaging().fcmToken! )
            senderVC.set(title: frat, channel: self.selectedChannel!, user: Auth.auth().currentUser!)
          }
          self.channelReferenceHandle = self.selectedChannel!.observe(.childAdded, with: { (snapshot) in
          if let newMessage = (snapshot.value as? Dictionary<String, AnyObject>) {
            if let content = newMessage["content"] as? String,
              let from = newMessage["fcmToken"] as? String {
              var message : LGChatMessage? = nil
              if from == Messaging.messaging().fcmToken {
                senderVC.addNewMessage = true
                message = LGChatMessage.init(content: content, sentBy: LGChatMessage.SentBy.User)
                senderVC.addNewMessage(message: message!) 
              }
              else {
                message = LGChatMessage.init(content: content, sentBy: LGChatMessage.SentBy.Opponent)
                senderVC.addNewMessage(message: message!) 
              }
              
              self.lastMessages[Pair(self.signedInAsFrat, indexPath.row)] = Pair(from, message!)
            }
          }
        })
        }
      }
    }
  }
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if let _ = Auth.auth().currentUser {
      return true
    }
    else {
      print("Blocked segue")
      return false
    }
  }
  
  
}
