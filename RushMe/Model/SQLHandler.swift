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
    coordinator!.encoding = .UTF8MB4
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
  
  func select(aField : String? = nil, fromTable : String? = nil, whereClause : String? = nil) -> [Dictionary<String, Any>]? {
    if user == nil {
      print("User initialization failed!")
      return nil
    }
    
    var queryString = "SELECT "
    if let _ = aField { queryString += aField! }
      else { queryString += "*" }
    if let _ = fromTable { queryString += " FROM " + fromTable! }
    if let _ = whereClause { queryString += " WHERE " + whereClause! }
    //queryString += ";"
    let query = OHMySQLQueryRequest(queryString: queryString)
    if let qContext = context {
      if let result = try? qContext.executeQueryRequestAndFetchResult(query) {
       return result
      }
      else {
        print("Failed on fetching query: " + queryString)
        return nil
      }
    }
    print("Failed on determining mainQueryContext")
    return nil
  }
  
  
  
  
  
  deinit {
   coordinator?.disconnect()
  }
  
}
