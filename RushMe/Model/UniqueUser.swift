//
//  UniqueUser.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/16/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import FirebaseAuth
fileprivate let sharedUserInstance = UniqueUser(openFromFile: true)

class UniqueUser: NSObject {
  var user : User? = nil {
    didSet {
     self.saveUser() 
    }
  }
  var anonymousUser : User? = nil 
  static var shared : UniqueUser {
    get {
      return sharedUserInstance
    }
  }
  var username : String? = "No Username" {
    didSet {
      self.saveUser() 
    } 
  }
  var password : String? = "No Password" {
    didSet {
      self.saveUser() 
    } 
  }
    

  fileprivate convenience init(openFromFile : Bool = false) {
    self.init()
    self.user = UniqueUser.loadUser() 
  }
  
  deinit {
    
  }
  
  func saveUser() {
    DispatchQueue.global().async {
      var dict = Dictionary<String, String>() 
      dict["username"] = self.username
      let isSuccessfulSave =  NSKeyedArchiver.archiveRootObject(self.user, toFile: RMFileManagement.userInfoURL.path)
      if !isSuccessfulSave {
        print("Errors with saving UniqueUser!")
      }
    }
  }
  static private func loadUser() -> User? {
    if let user = NSKeyedUnarchiver.unarchiveObject(withFile: RMFileManagement.favoritedFratURL.path) as? User{
      return nil //return user
    }
    else {
      return nil
    }
  }

}


