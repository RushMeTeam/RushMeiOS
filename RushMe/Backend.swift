//
//  SQLHandler.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/15/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import Foundation
import CoreLocation.CLLocation


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
  
  static let db = "http://ec2-18-188-8-243.us-east-2.compute.amazonaws.com/request.php"
  static let S3 = "https://s3.us-east-2.amazonaws.com/rushmepublic/"
  
  static var pastActionsFromFile : Array<Dictionary<String, Any>> {
    set {
      DispatchQueue.global(qos: .background).async {
        guard NSKeyedArchiver.archiveRootObject(newValue, toFile: User.files.userActionsURL.path) else {
          print("Error Saving Actions!")
          return
        }
      }
    }
    get {
      if let actions = 
        NSKeyedUnarchiver.unarchiveObject(withFile: User.files.userActionsURL.path) 
          as? [Dictionary<String, Any>] {
        return actions 
      }
      self.pastActionsFromFile = [Dictionary<String, Any>]()
      return []
    }
  }
  
  // Select everything from a SQL table using its name
  static func selectAll(fromTable tableName : String ) throws -> [Dictionary<String, Any>]  {
    let tableString = "\(tableName)" //"?table=\(tableName)"
    guard let url = URL(string: Backend.S3 + tableString) else {
      print("Bad Request!")
      throw BackendError.badRequest
    }; guard let response = try? Data(contentsOf: url) else {
      print("No Response!")
      throw BackendError.nullServerResponse
    }; guard let jsonObject = 
      try? JSONSerialization.jsonObject(with: response, options: .allowFragments)
      else {
        print("Bad JSON!")
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
    self.init(url: URL(string: Backend.db)!)
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
      static let fraternities = "fraternites.rushme"
      static let events = "events.rushme"
    }
    struct frat {
      static let name = "name"
      static let key = "namekey"
      static let coordinates = "coordinates"
      static let chapter = "chapter"
      static let memberCount = "member_count"
      static let description = "description"
      static let gpa = "gpa"
      static let address = "address"
      static let previewImage = "preview_image"
      static let profileImage = Database.keys.frat.key
      static let coverImage = "cover_image"
      static let calendarImage = Database.keys.frat.key
      
    }
    struct event {
      static let name = "event_name"
      static let fratKey = "frat_name_key"
      static let description = "description"
      static let startTime = "start_time"
      static let inviteOnly = "invite_only"
      static let duration = "duration"
      static let location = "location"
      static let coordinates = "coordinates"
    }
  }
}

// TODO: Empty this file
// Variables used to tune animations
struct RMAnimation {
  static let ColoringTime = 0.5
}
// TODO: Make user preferences save (should include display events before today!)
struct RushMe {
  struct campus {
    static let coordinates = CLLocationCoordinate2D(latitude: 42.729305, longitude: -73.677647)
  }
}
struct RMPropertyKeys {
  static let FavoriteFraternities = "FavoriteFrats"
  static let ConsiderEventsBeforeTodayKey = "ConsiderEventsBeforeToday"
}
extension Date {
  // TODO: Replace "Today" with the current day!
  static var today : Date {
    get {
      return Date()//Date(timeIntervalSince1970: 1505036460) 
    }
  }
  
  var month : Int {
    get {
      return UIKit.Calendar.current.component(.month, from: self)
    }
  }
  var day : Int {
    get {
      return UIKit.Calendar.current.component(.day, from: self)
    }
  }
  var year : Int {
    get {
      return UIKit.Calendar.current.component(.year, from: self)
    }
  }
  var weekday : Int {
    get {
      return UIKit.Calendar.current.component(.weekday, from: self)
    }
  }
}


extension RushCalendar {
  func add(eventDescribedBy dict : Dictionary<String, Any>) -> Fraternity.Event? {
    //house, event_name, start_time, end_time, event_date, location
    // start_time, end_time, location possibly nil
    guard let houseName = dict[Database.keys.event.fratKey] as? String,
      let eventName = dict[Database.keys.event.name] as? String,
      let eventDateRaw = dict[Database.keys.event.startTime] as? String,
      let eventDate = User.device.iso8601.date(from: eventDateRaw + ":00+00:00"),
      let frat = Campus.shared.fraternitiesByKey[houseName]
      else {
        print("Event error!")
        return nil   
      
    }
    var interval = 0.0
    if let durationRaw = (dict[Database.keys.event.duration] as? String)?.split(separator: ":"),
      let hours = Int(durationRaw[0]),
      let mins = Int(durationRaw[1]){
      interval = Double(((hours * 60) + mins) * 60)
    }
    let location = dict[Database.keys.event.location] as? String
    if let event = Fraternity.Event(withName: eventName,
                                    on: eventDate, 
                                    heldBy: frat,
                                    duration: interval,
                                    at: location) {
      return add(event: event) ? event : nil
    } 
    return nil
  }
  
}

func getString(_ key : String, _ dict : Dictionary<String, Any>) -> String? {
  guard let result = dict[key] as? String else {
   print("No dice...")
    return nil
  }
  return result
}
func getInt(_ key : String, _ dict : Dictionary<String, Any>) -> Int? {
  guard let result = dict[key] as? Int else {
    print("No dice...")
    return nil
  }
  return result
}
extension Fraternity {
  convenience init?(withDictionary dict : Dictionary<String, Any>) {
    guard 
      let key = dict[Database.keys.frat.key] as? String,
      key.count == 3,
      let name = dict[Database.keys.frat.name] as? String,
      let description = dict[Database.keys.frat.description] as? String,
      let chapter = dict[Database.keys.frat.chapter] as? String,
      let memberCountRaw = dict[Database.keys.frat.memberCount] as? String,
      let memberCount = Int(memberCountRaw)
      else {
        print("Failed to create fraternity!")
        return nil 
    }
    
    var cImagePath : RMURL?
    if let calendarImagePathRaw = dict[Database.keys.frat.calendarImage] as? String {
      cImagePath = RMURL(fromString: calendarImagePathRaw)
    }
    var coImagePaths = [RMURL]()
    if let coverImagePathRaw = dict[Database.keys.frat.coverImage] as? String,
      let path = RMURL(fromString: coverImagePathRaw) {
      coImagePaths.append(path)
    }
    let pImagePath = RMURL(fromString: key + "prof")    
    
    let address = dict[Database.keys.frat.address] as? String
    var coords : CLLocationCoordinate2D?
    if let _ = address, address!.lowercased() != "no house", 
       let coordinates = dict[Database.keys.frat.coordinates] as? [Double] {
      coords = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
    self.init(key: key,                         name: name, 
              description: description,         chapter: chapter, 
              memberCount : memberCount,        profileImagePath: pImagePath, 
              calendarImagePath: cImagePath,    coverImagePaths: coImagePaths, 
              address: address,                 coordinates: coords)
  }
}
