//
//  SQLHandler.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/15/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import OHMySQL

enum RMAction : String {
  typealias RawValue = String
  case FraternitySelected = "Fraternity Selected"
  case FraternityFavorited = "Fraternity Favorited"
  case FraternityUnfavorited = "Fraternity Unfavorited"
  case UserNavigated = "User Navigated"
  case AppEnteredForeground = "App Entered Foreground"
  case AppWillEnterBackground = "App Entering Background"
  case SQLError = "SQL Error Encountered"
}

// Centralize requests made to an SQL server
class SQLHandler  {
  let user : OHMySQLUser!
  let coordinator : OHMySQLStoreCoordinator
  private(set) lazy var parentContext : OHMySQLQueryContext = {
    let context = OHMySQLQueryContext() 
    context.storeCoordinator = coordinator
    return context
  }()
  var newContext : OHMySQLQueryContext {
    get {
      let context = OHMySQLQueryContext.init(parentQueryContext: parentContext)
      context.storeCoordinator = coordinator
      return context
    }
  }
  var pastActionsFromFile : Array<Dictionary<String, Any>> {
    set {
      DispatchQueue.global(qos: .background).async {
        if !NSKeyedArchiver.archiveRootObject(newValue, toFile: RMFileManagement.userActionsURL.path) {
          print("Error in Saving Actions!")
        }
//        else {
//          print("Successful Action Save!")
//        }
      }
    }
    get {
      if let actions = NSKeyedUnarchiver.unarchiveObject(withFile: RMFileManagement.userActionsURL.path) as? [Dictionary<String, Any>] {
       return actions 
      }
      else {
        self.pastActionsFromFile = Array<Dictionary<String, Any>>()
      }
      return []
    }
  }
  // "name","description","chapter","members","cover_image","profile_image","calendar_image","preview_image","address"
  fileprivate init(userName: String,
                   password: String,
                   serverIP: String,
                   dbName: String,
                   port: UInt,
                   socket: String?) {
    user = OHMySQLUser(userName: userName, password: password,
                       serverName: serverIP,
                       dbName: dbName,
                       port: port,
                       socket: socket)
    coordinator = OHMySQLStoreCoordinator(user: user)
    coordinator.encoding = .UTF8MB4
    parentContext.storeCoordinator = coordinator
    if !coordinator.isConnected {
      self.coordinator.connect()
    }
    pushAll()
  }
  
  
  static let shared : SQLHandler = SQLHandler.init(userName: RMNetwork.userName,
                                                                      password: RMNetwork.password,
                                                                      serverIP: RMNetwork.IP,
                                                                      dbName: RMNetwork.databaseName,
                                                                      port: 3306,
                                                                      socket: nil)
  func select(fromTable : String, conditions : String? = nil, disconnectAfterQuery : Bool = false) -> [Dictionary<String, Any>]? {
    if coordinator.pingMySQL() != .none {
     return nil 
    }
    pushAll()
    let query = OHMySQLQueryRequestFactory.select(fromTable, condition: conditions)
    let qContext = parentContext
    qContext.storeCoordinator = coordinator
    do {
      return try (qContext.executeQueryRequestAndFetchResult(query), disconnectAfterQuery ? coordinator.disconnect() : nil).0
    }
    catch let e {
      self.inform(action: .SQLError, options: e.localizedDescription)
      print(e.localizedDescription)
      return nil 
    }
    
  }
  private(set) var isPushing = false
  private func pushAll() {
    coordinator.connect()
    guard !isPushing else {
     return 
    }
    isPushing = true
    var pastActions = pastActionsFromFile
    while let action = pastActions.last {
      if push(action: action) {
        _ = pastActions.popLast()
        //DispatchQueue.global(qos: .utility).async {
          self.pastActionsFromFile = pastActions
        //}
      }
      else {
        print("Failed to Push Action: \(action)")
        return 
      }
    }
    //print("Pushed Actions: \(pastActionsFromFile)")
    self.pastActionsFromFile = []
    self.isPushing = false
  }
  private func push(action : [String : Any]) -> Bool {
    let query = OHMySQLQueryRequestFactory.insert(RMNetwork.userActionsTableName, set: action)
    let qContext =  self.parentContext
    qContext.storeCoordinator = self.coordinator
    do {
      try qContext.execute(query)
      return true
    }
    catch let querryError {
      print("Error pushing action:\n\t\(String(describing: action["action"]))\n\tError: \(querryError.localizedDescription)")
      return false
    }
  }
  
  func inform(action : RMAction, options : String? = nil, additionalInfo : [String : Any]? = nil) {
    DispatchQueue.global(qos: .utility).async {
      var report = RMUserDevice().deviceInfo
      report["action"] = action.rawValue
      if let subseqOptions = (options?.split(separator: ";").first) {
        report["options"] = String(subseqOptions)
      }
      if action == .AppWillEnterBackground {
        self.pushAll()
      }
      else {
        self.pastActionsFromFile.append(report)
      }
      
    }
    
    
  }
  
  
  deinit {
    coordinator.disconnect()
  }
  
}
