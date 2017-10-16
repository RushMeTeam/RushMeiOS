//
//  SQLHandler.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/15/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import OHMySQL

class SQLHandler: NSObject {
  let user : OHMySQLUser?
  let coordinator : OHMySQLStoreCoordinator?
  let context : OHMySQLQueryContext?
  // "name","description","chapter","members","cover_image","profile_image","calendar_image","preview_image","address"
  override init() {
    user = OHMySQLUser(userName: "root", password: "",
                       serverName: "127.0.0.1",
                       dbName: "fratinfo",
                       port: 3306,
                       socket: nil)
    coordinator = OHMySQLStoreCoordinator(user: user!)
    coordinator!.encoding = .UTF8MB4
    coordinator!.connect()
    context = OHMySQLQueryContext()
    context!.storeCoordinator = coordinator!
    super.init()
  }
  
  func select(aField : String, fromTable : String? = nil) -> [Dictionary<String, Any>]? {
    var queryString = "SELECT " + aField
    if let _ = fromTable {
     queryString += " FROM " + fromTable!
    }
    queryString += " ;"
    let query = OHMySQLQueryRequest(queryString: queryString)
    if let qContext = context {
      if let result = try? qContext.executeQueryRequestAndFetchResult(query) {
       return result
      }
      else {
        print("Failed on fetching query.")
        return nil
      }
    }
    print("Failed on determining mainQueryContext")
    return nil
  }
  
}
