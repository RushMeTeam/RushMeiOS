//
//  SQLHandler.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/15/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

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
  static var pastActionsFromFile : Array<Dictionary<String, Any>> {
    set {
      DispatchQueue.global(qos: .background).async {
        if !NSKeyedArchiver.archiveRootObject(newValue, toFile: RMFileManagement.userActionsURL.path) {
          print("Error in Saving Actions!")
        }
      }
    }
    get {
      if let actions = NSKeyedUnarchiver.unarchiveObject(withFile: RMFileManagement.userActionsURL.path) as? [Dictionary<String, Any>] {
       return actions 
      }
      else {
        self.pastActionsFromFile = [Dictionary<String, Any>]()
      }
      return []
    }
  }
  // "name","description","chapter","members","cover_image","profile_image","calendar_image","preview_image","address"
 
  static func select(fromTable : String ) -> [Dictionary<String, Any>]? {
    let tableString = "?table=\(fromTable)"
    if let url = URL(string: RMNetwork.web.absoluteString + tableString), 
      let response = try? Data.init(contentsOf: url) {
      return try! JSONSerialization.jsonObject(with: response, options: .allowFragments) as? [Dictionary<String, Any>] 
    }
    else {
     print("Failed Select") 
    }
    
    return nil
  }
  static private(set) var isPushing = false
  private static func pushAll() {
    //coordinator.connect()
    guard !isPushing else {
     return
    }
    isPushing = true
    while let action = pastActionsFromFile.popLast() {
      SQLHandler.push(action: action)
    }
    //print("Pushed Actions: \(pastActionsFromFile)")
    self.pastActionsFromFile = []
    self.isPushing = false
  }
  private static func push(action : [String : Any]) {
    DispatchQueue.global(qos: .background).async {
      var request = URLRequest.init(url: RMNetwork.web)
      request.httpMethod = "POST"
      var actionAsString = "&"
      for category in action {
        actionAsString += "\(category.key)=\((category.value as? String)  ?? "NULL")&"
      }
      request.httpBody = actionAsString.data(using: .utf8)
      URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else {
          print("Push Error:", error!) 
          return
        }
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
          print("Push Error:\n\tStatus Code is not 200! (httpStatusCode \(httpStatus.statusCode))") 
          //SQLHandler.pastActionsFromFile.append(action)
        }
        if let responseString = String.init(data: data, encoding: .utf8), responseString.count > 0 {
//          print("Data Sent:", String.init(data: request.httpBody!, encoding: .utf8)!)
          print("Server Reponse:", responseString)
        }
        }.resume()
    }
  }
  static func inform(action : RMAction, options : String? = nil, additionalInfo : [String : Any]? = nil) {
    DispatchQueue.global(qos: .utility).async {
      var report = RMUserDevice().deviceInfo
      report["pact"] = action.rawValue
      if let subseqOptions = (options?.split(separator: ";").first) {
        report["popt"] = String(subseqOptions)
      }
      if action == .AppEnteredForeground || action == .AppWillEnterBackground {
        pushAll() 
      }
      else {
        push(action: report)
      }
      
      
      
    }
  }
}
