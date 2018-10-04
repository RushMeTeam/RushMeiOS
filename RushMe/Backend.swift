//
//  SQLHandler.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/15/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import Foundation

enum ActionType : String {
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
class Backend {
  fileprivate static let databaseName = "fratinfo"
  fileprivate static let userActionsTableName = "sqlrequests"
  fileprivate static let userName = "RushMePublic"
  static let db = URL(string: "http://ec2-18-188-8-243.us-east-2.compute.amazonaws.com/request.php")!
  static let S3 = URL(string: "https://s3.us-east-2.amazonaws.com/rushmepublic/")!
  static var pastActionsFromFile : Array<Dictionary<String, Any>> {
    set {
      DispatchQueue.global(qos: .background).async {
        if !NSKeyedArchiver.archiveRootObject(newValue, toFile: User.files.userActionsURL.path) {
          print("Error Saving Actions!")
        }
      }
    }
    get {
      if let actions = NSKeyedUnarchiver.unarchiveObject(withFile: User.files.userActionsURL.path) as? [Dictionary<String, Any>] {
       return actions 
      }
      else {
        self.pastActionsFromFile = [Dictionary<String, Any>]()
      }
      return []
    }
  }
  // Grab everything from a SQL table using it's name
  static func selectAll(fromTable tableName : String ) -> [Dictionary<String, Any>]? {
    let tableString = "?table=\(tableName)"
    if let url = URL(string: Backend.db.absoluteString + tableName), 
      let response = try? Data.init(contentsOf: url) {
      return (try? JSONSerialization.jsonObject(with: response, options: .allowFragments)) as? [Dictionary<String, Any>] 
    }
    else {
     print("Failed Select") 
    }
    
    return nil
  }
  // Used to determine whether the App is currently in the process of 
  //    pusing user actions to the database
  static private(set) var isPushing = false
  // Push multiple stored/cached actions
  private static func pushAllActions() {
    //coordinator.connect()
    guard !isPushing else {
     return
    }
    isPushing = true
    while let action = pastActionsFromFile.popLast() {
      Backend.push(action: action)
    }
    //print("Pushed Actions: \(pastActionsFromFile)")
    self.pastActionsFromFile = []
    self.isPushing = false
  }
  private static func push(action : [String : Any]) {
    if Privacy.policyAccepted {
      DispatchQueue.global(qos: .background).async {
        var request = URLRequest.init(url: Backend.db)
        request.httpMethod = "POST"
        var actionAsString = "&"
        for category in action {
          actionAsString += "\(category.key)=\((category.value as? String)  ?? "NULL")&"
        }
        request.timeoutInterval = 10
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
  }
  static func inform(action : ActionType, options : String? = nil, additionalInfo : [String : Any]? = nil) {
    DispatchQueue.global(qos: .utility).async {
      var report = User.device.properties
      report["pact"] = action.rawValue
      if let subseqOptions = (options?.split(separator: ";").first) {
        report["popt"] = String(subseqOptions)
      }
      if action == .AppEnteredForeground || action == .AppWillEnterBackground {
        pushAllActions() 
      } else {
        push(action: report)
      }
    }
  }
}

// TODO: Move this into the Backend Struct
struct Database {
  struct keys {
    struct database {
      static let fraternities = "house_info"
      static let events = "events"
    }
    struct frat {
      static let name = "name"
      static let chapter = "chapter"
      static let memberCount = "members"
      static let description = "description"
      static let gpa = "gpa"
      static let address = "address"
      static let previewImage = "preview_image"
      static let profileImage = "profile_image"
      static let coverImage = "cover_image"
      static let calendarImage = "calendar_image"
    }
  }
}

