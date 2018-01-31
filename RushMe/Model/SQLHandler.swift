//
//  SQLHandler.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/15/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import OHMySQL

fileprivate let sharedSQLHandler = SQLHandler.init(userName: RMNetwork.userName,
                                       password: RMNetwork.password,
                                       serverIP: RMNetwork.IP,
                                       dbName: RMNetwork.databaseName,
                                       port: 3306,
                                       socket: nil)

// Centralize requests made to an SQL server
class SQLHandler: NSObject {
  let user : OHMySQLUser?
  let coordinator : OHMySQLStoreCoordinator?
  let context : OHMySQLQueryContext?
  var isConnected : Bool {
    get {
     return user != nil && coordinator != nil
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
    coordinator = OHMySQLStoreCoordinator(user: user!)
    //coordinator!.encoding = .UTF8MB4
    coordinator!.connect()
    context = OHMySQLQueryContext()
    
    context!.storeCoordinator = coordinator!
    super.init()
    
  }
  static var shared : SQLHandler {
    get {
      return sharedSQLHandler 
    }
  }
  
  func select(fromTable : String, conditions : String? = nil) -> [Dictionary<String, Any>]? {
    let query = OHMySQLQueryRequestFactory.select(fromTable, condition: conditions)
    let qContext = self.context ?? OHMySQLQueryContext()
    qContext.storeCoordinator = coordinator!
    if let response = try? qContext.executeQueryRequestAndFetchResult(query) {
      return response
    }
    else {
     return nil
    }
  }
  func informAction(action : String, options : String? = nil, additionalInfo : [String : Any]? = nil) {
    DispatchQueue.global(qos: .background).async {
      var report = RMUserDevice.deviceInfo
      report["action"] = action
      report["options"] = options
      let query = OHMySQLQueryRequestFactory.insert(RMNetwork.userActionsTableName, set: report)
      let qContext =  self.context ?? OHMySQLQueryContext()
      qContext.storeCoordinator = self.coordinator!
      do {
        try qContext.executeQueryRequestAndFetchResult(query)
      }
      catch let querryError {
        if querryError.localizedDescription != "The operation couldn’t be completed. (Foundation._GenericObjCError error 0.)" {
          print("Insert Error: " + querryError.localizedDescription)
        }
      }
    }
    
    
  }
  
  
  deinit {
   coordinator?.disconnect()
  }
  
}
