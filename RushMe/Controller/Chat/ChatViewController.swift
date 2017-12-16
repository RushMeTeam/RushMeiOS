//
//  ChatViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/10/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import Firebase
// Uses Chatto
class ChatViewController: LGChatController, LGChatControllerDelegate {
  private var selectedChannel : String? 
  func set(channel : String, user: User) {
    self.selectedChannel = channel
    self.user = user
    self.title = channel
    channelRef.keepSynced(true)
    cRef = Database.database().reference().child(channel).child(user.uid)
    cRef.keepSynced(true)
    channelReferenceHandle = channelRef.observe(.childAdded, with: { (snapshot) in
      if let channelData = snapshot.value as? Dictionary<String, AnyObject>  {
        //let id = snapshot.key
        if let content = channelData["content"] as? String, let from = channelData["from"] as? String, !content.isEmpty {
          print("Success pushing message" + content)
          if from == self.user?.uid {
            //self.addNewMessage(message: LGChatMessage.init(content: content, sentBy: LGChatMessage.SentBy.User))
            // No need to add a message already on the screen
          }
          else {
            self.addNewMessage(message: LGChatMessage.init(content: content, sentBy: LGChatMessage.SentBy.Opponent))
          }
        }
        else {
          print("Error with adding new message to database!!") 
        }
      }
      else {
        print("Could not unwrap snapshot data") 
      }
    }) 
  }

  
  private lazy var cRef : DatabaseReference = Database.database().reference()
  private var channelRef : DatabaseReference {
    get {
      return cRef
    }
  }
  private var selfRef : DatabaseReference?
  private var channelReferenceHandle : DatabaseHandle?
  var user : User? 
    override func viewDidLoad() {
        super.viewDidLoad()
        
      self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
//      if (self.revealViewController() != nil) {
//        // Allow drawer button to toggle the lefthand drawer menu
//        drawerButton.target = self.revealViewController()
//        drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
//        // Allow drag to open drawer, tap out to close
//        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
//      }
      self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
      self.delegate = self
      
      //if let _ = selfRef {
        // Do any additional setup after loading the view.
        
      //}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
    
    print("Added a message " + message.content + " to sfirecreen")
  }
  
  deinit {
    //channelRef.removeObserver(withHandle: handle)
    channelReferenceHandle = nil
    
  }
  func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
    if let channel = self.selectedChannel {
      let newChannelReference = channelRef.child(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .full))
      let channelItem = [
      "to" : channel,
      "from" : self.user?.uid,
      "content" : message.content
    ]
    newChannelReference.setValue(channelItem)
    }
    return true
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
