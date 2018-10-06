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
  
  enum BackendError : Error {
    case nullServerResponse
    case invalidServerResponse(withCode : Int)
    case invalidServerResponse(withCode : Int, response : String?)
    case jsonParseError(from : Data)
    case badRequest
  }
  
  fileprivate static let databaseName = "fratinfo"
  fileprivate static let userActionsTableName = "sqlrequests"
  
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
      self.pastActionsFromFile = [Dictionary<String, Any>]()
      return []
    }
  }
  
  // Select everything from a SQL table using its name
  static func selectAll(fromTable tableName : String ) throws -> [Dictionary<String, Any>]  {
    let tableString = "?table=\(tableName)"
    guard let url = URL(string: Backend.db.absoluteString + tableString) else {
      throw BackendError.badRequest
    }; guard let response = try? Data(contentsOf: url) else {
      throw BackendError.nullServerResponse
    }; guard let jsonObject = 
      try? JSONSerialization.jsonObject(with: response, options: .allowFragments)
    else {
        throw BackendError.jsonParseError(from: response)
    }
    return jsonObject as? [Dictionary<String, Any>] ?? [] 
  }
  
  // Used to determine whether the App is currently in the process of 
  // uploading (pushing) user actions to the database
  static private(set) var isPushing = false
  
  private static func handleResponse(_ data : Data?,_ response : URLResponse?,_ error : Error?) throws {
    guard let data = data, error == nil else {
      print("Push Error:", error!) 
      return
    }
    let httpStatus = response as? HTTPURLResponse
    switch httpStatus?.statusCode {
    case nil:
      throw BackendError.nullServerResponse
    case 200: 
      break
    default:
      //print("Push Error:\n\tHTTPStatus:\t\(httpStatus!.statusCode)\n\tHTTPResponse:\t\(String(data: data, encoding: .utf8) ?? "None")")
      throw BackendError.invalidServerResponse(withCode: httpStatus!.statusCode, 
                                               response: String(data: data, encoding: .utf8))
    }
  }
  
  private static func push(action : [String : Any]) {
    guard Privacy.policyAccepted else { return }
    DispatchQueue.global(qos: .background).async {
      let request = URLRequest(fromAction: action)
      URLSession.shared.dataTask(with: request) {  
        (data, response, error) in try? handleResponse(data, response, error) 
      }.resume()
    }
  }
  
  // Push multiple stored/cached actions
  private static func pushAll() {
    guard !isPushing else { return }
    isPushing = true
    while let action = pastActionsFromFile.popLast() {
      Backend.push(action: action)
    }
    self.pastActionsFromFile = []
    self.isPushing = false
  }
  
  
  static func log(action : ActionType, options : String? = nil) {
    DispatchQueue.global(qos: .utility).async {
      let actionReport = report(fromAction: action)
      if action == .AppEnteredForeground || 
         action == .AppWillEnterBackground {
        pushAll() 
      } else {
        push(action: actionReport)
      }
    }
  }
  private static func report(fromAction action : ActionType, options : String? = nil) -> [String : Any] {
    var report = User.device.properties
    report["pact"] = action.rawValue
    if let subseqOptions = (options?.split(separator: ";").first) {
      report["popt"] = String(subseqOptions)
    }
    return report
  }
  
}

fileprivate extension URLRequest {
  init(fromAction action : [String : Any]) {
    self.init(url: Backend.db)
    self.httpMethod = "POST"
    var actionAsString = "&"
    for category in action {
      actionAsString += "\(category.key)=\((category.value as? String)  ?? "NULL")&"
    }
    self.timeoutInterval = 10
    self.httpBody = actionAsString.data(using: .utf8)
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

