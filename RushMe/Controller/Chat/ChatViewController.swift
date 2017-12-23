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
  private var selectedChannel : DatabaseReference? 
  private var channelTitle : String? {
    didSet {
      if let _ = channelTitle {
        self.title = channelTitle 
      }
    }
  }
  func set(title : String, channel : DatabaseReference, user: User) {
    self.selectedChannel = channel
    self.user = user
    self.channelTitle = title
    self.selectedChannel!.keepSynced(true)
    selectedChannel?.queryLimited(toLast: 25)
  }
  var addNewMessage = true
  private var selfRef : DatabaseReference?
  private var channelReferenceHandle : DatabaseHandle?
  var user : User? 
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    self.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
    print("Added a message \"" + message.content + "\" to device screen")
  }
  
  func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
    if let _ = self.selectedChannel, let _ = self.channelTitle, addNewMessage {
      let sendDateString = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .full)
      let newChannelReference = self.selectedChannel!.child(sendDateString)
      let channelItem = [
        "to" : self.channelTitle,
        "from" : Auth.auth().currentUser!.uid,
        "fcmToken" : Messaging.messaging().fcmToken,
        "content" : message.content,
        "sendDate" : sendDateString,
        "timeStamp" : String(Date().timeIntervalSinceReferenceDate),
        "messageNumber" : String(messages.count)
      ]
      //Messaging.messaging().sendMessage(channelItem, to: "632745064590", withMessageID: String(Date().timeIntervalSinceReferenceDate), timeToLive: 1024)
      
      addNewMessage = true
      print("Adding message: \"\(message.content)\" to Database")
      newChannelReference.setValue(channelItem)
      return false
    }
    else {
      if self.selectedChannel == nil {
        print("Failed because selectedChannel is nil!") 
      }
      else if self.channelTitle == nil {
        print("Failed because channelTitle is nil!") 
      }
    }
    addNewMessage = false
    return false
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
