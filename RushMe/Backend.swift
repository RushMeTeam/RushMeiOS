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
  case EventSubscribed = "Event Subscribed"
  case EventUnsubscribed = "Event Unsubscribed"
  case UserNavigated = "User Navigated"
  case AppEnteredForeground = "App Entered Foreground"
  case AppWillEnterBackground = "App Entering Background"
  case SQLError = "iOS: SQL Error Encountered"
}


enum Action {
  case Selected(fraternity : Fraternity)
  case Favorited(fraternity : Fraternity)
  case Unfavorited(fraternity : Fraternity)
  case Subscribed(event : Fraternity.Event)
  case Unsubscribed(event : Fraternity.Event)
  case Navigated(to : String)
  case AppEnteredForeground
  case AppWillEnterBackground
  case Error(type : NetworkFailure)
}

enum NetworkFailure : String {
  case Unknown = "Unknown"
  case Download = "Download"
  case Upload = "Upload"
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
  
  /**
   This function is used only for server wide errors. It is essentially a way to determine the status of the server
   to report to the user. This should only be called conditionally if the client is unable to determine the reason for
   a lack of fraternity data.
   */
  static func serverStatus() -> String {
    // Retrieve information from S3
    let error_path = Backend.S3 + "err.rushme"
    
    var error_msg = "operational"
    do {
      // Parse the data into JSON
      let dataFromURL = try Data(contentsOf: URL(string: error_path)!)
      let jsonObject = try? JSONSerialization.jsonObject(with: dataFromURL, options: .allowFragments)
      error_msg = (jsonObject as! [String: Any])["blockingError"] as! String
    } catch {
      error_msg = "Could not connect to file server"
    }
    
    return error_msg
  }
  
  // Select everything from a SQL table using its name
  static func selectAll(fromTable tableName : String ) throws -> [Dictionary<String, Any>]  {
    let tableString = "\(tableName)"
    guard let url = URL(string: Backend.S3 + tableString) else {
      print("Bad Request for: \(tableName)")
      throw BackendError.badRequest
    }; guard let response = try? Data(contentsOf: url) else {
      print("No Response for: \(tableName)")
      throw BackendError.nullServerResponse
    }; guard let jsonObject =
      try? JSONSerialization.jsonObject(with: response, options: .allowFragments)
      else {
        print("Bad JSON for: \(tableName)")
        throw BackendError.jsonParseError(from: response)
    }; guard let output = jsonObject as? [Dictionary<String, Any>] else {
      if let output = jsonObject as? Dictionary<String, Any> {
        return [output]
      }
      print("Bad JSON container for: \(tableName)")
      return []
    }
    return output
  }
  
  // Used to determine whether the App is currently in the process of
  // uploading (pushing) user actions to the database
  static private(set) var isPushing = false
  
  private static func handleResponse(_ data : Data?,_ response : URLResponse?,_ error : Error?) throws {
    guard let data = data, error == nil else {
      print("Push Error:", error!)
      return
    }
    guard let httpStatus = response as? HTTPURLResponse else {
      print("No response!")
      return
    }
    switch httpStatus.statusCode {
    case nil:
      print("Error/Backend: No response!")
      throw BackendError.nullServerResponse
    case 200:
      if let response = String(data: data, encoding: .utf8), response.count > 0 {
        print("Success/Backend: \(response)")
      }
      break
    default:
      print("Push Error:\n\tHTTPStatus:\t\(httpStatus.statusCode)")
      print("\tHTTPResponse:\t\(String(data: data, encoding: .utf8) ?? "None")")
      throw BackendError.invalidServerResponse(withCode: httpStatus.statusCode,
                                               response: String(data: data, encoding: .utf8))
    }
  }
  
  private static func push(action : [String : Any]) {
    guard Privacy.policyAccepted else {
      return
    }
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
  
  
  static func log(action : Action, options : String? = nil) {
    DispatchQueue.global(qos: .utility).async {
      let actionReport = report(action: action)
      switch action {
      case Action.AppEnteredForeground:
        pushAll()
      case Action.AppWillEnterBackground:
        pushAll()
      default:
        push(action: actionReport)
      }
    }
  }
  private static func report(action : Action) -> [String : Any] {
    var report = User.device.properties
    switch action {
    case .Selected(let fraternity):
      report["pact"] = ActionType.FraternitySelected
      report["popt"] = fraternity.name
      break
    case .Favorited(let fraternity):
      report["pact"] = ActionType.FraternityFavorited
      report["popt"] = fraternity.name
      break
    case .Unfavorited(let fraternity):
      report["pact"] = ActionType.FraternityUnfavorited
      report["popt"] = fraternity.name
      break
    case .Navigated(let to):
      report["pact"] = ActionType.UserNavigated
      report["popt"] = to
      break
    case .AppEnteredForeground:
      report["pact"] = ActionType.AppEnteredForeground
    case .AppWillEnterBackground:
      report["pact"] = ActionType.AppWillEnterBackground
    case .Error(let description):
      report["pact"] = ActionType.SQLError
      report["popt"] = description
      break
    case .Subscribed(let event):
      report["pact"] = ActionType.EventSubscribed
      report["popt"] = "\(event.frat.name)-\(event.name)"
      break
    case .Unsubscribed(let event):
      report["pact"] = ActionType.EventUnsubscribed
      report["popt"] = "\(event.name) by \(event.frat.name)"
      break
    }
    report["pact"] = (report["pact"] as! ActionType).rawValue
    return report
  }
  
}

fileprivate extension URLRequest {
  init(fromAction action : [String : Any]) {
    self.init(url: URL(string: Backend.db)!)
    self.httpMethod = "POST"
    var actionAsString = "&"
    action.forEach { (parameters) in
      actionAsString += "\(parameters.key)=\((parameters.value as? String)  ?? "NULL")&"
    }
    self.timeoutInterval = 10
    print(actionAsString)
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
      static let name = "name"       ; static let coverImage = "cover_image"
      static let chapter = "chapter" ; static let coordinates = "coordinates"
      static let gpa = "gpa"         ; static let memberCount = "member_count"
      static let address = "address" ; static let description = "description"
      static let key = "namekey"     ; static let previewImage = "preview_image"
      static let profileImage = Database.keys.frat.key
      static let calendarImage = Database.keys.frat.key
    }
    struct event {
      static let name = "event_name"      ; static let fratKey = "frat_name_key"
      static let duration = "duration"    ; static let inviteOnly = "invite_only"
      static let startTime = "start_time" ; static let description = "description"
      static let location = "location"    ; static let coordinates = "coordinates"
    }
  }
}



let defaultCoordinates = CLLocationCoordinate2D(latitude: 42.729305, longitude: -73.677647)


extension Date {
  static var today : Date {
    get { return (User.debug.debugDate ?? Date()).dayDate }
  }
  var minute : Int {
    get { return UIKit.Calendar.current.component(.minute, from: self) }
  }
  var hour : Int {
    get { return UIKit.Calendar.current.component(.hour, from: self) }
  }
  var month : Int {
    get { return UIKit.Calendar.current.component(.month, from: self) }
  }
  var day : Int {
    get { return UIKit.Calendar.current.component(.day, from: self) }
  }
  var year : Int {
    get { return UIKit.Calendar.current.component(.year, from: self) }
  }
  var weekday : Int {
    get { return UIKit.Calendar.current.component(.weekday, from: self) }
  }
}

extension RushCalendar {
  func add(eventDescribedBy dict : Dictionary<String, Any>) -> Fraternity.Event? {
    //house, event_name, start_time, end_time, event_date, location
    // start_time, end_time, location possibly nil
    guard let houseName = dict[Database.keys.event.fratKey] as? String else {
      print("Could not initialize event component: house name")
      return nil
    }
    guard let frat = Campus.shared.fraternitiesByKey[houseName] else {
      print("Could not retrieve \(houseName)'s Fraternity object")
      return nil
    }
    guard  let eventName = dict[Database.keys.event.name] as? String else {
      print("Could not initialize \(houseName)'s event's name")
      return nil
    }
    guard  let eventDateRaw = dict[Database.keys.event.startTime] as? String else {
      print("Could not initialize \(houseName)'s event's startTime (as String)")
      return nil
    }
    guard let eventDate = User.device.iso8601.date(from: eventDateRaw + ":00+00:00") else {
      print("Could not initialize \(houseName)'s event's endDate \(eventDateRaw) (as Date)")
      return nil
    }
    
    var interval = 0.0
    if let durationRaw = (dict[Database.keys.event.duration] as? String)?.split(separator: ":"),
      let hours = Int(durationRaw[0]),
      let mins = Int(durationRaw[1]){
      interval = Double(((hours * 60) + mins) * 60)
    } else if let duration = dict[Database.keys.event.duration] as? String {
      print("Could not unpackage or initialize event duration \(duration)")
    }
    let location = dict[Database.keys.event.location] as? String
    guard let event = Fraternity.Event(withName: eventName,  on: eventDate,
                                       heldBy: frat,         duration: interval,
                                       at: location)  else { return nil }
    return add(event: event) ? event : nil
  }
  
}

extension Fraternity {
  convenience init?(withDictionary dict : Dictionary<String, Any>) {
    guard let key = dict[Database.keys.frat.key] as? String else {
      print("Could not initialize fraternity component: house key (no entry)")
      return nil
    }
    guard key.count == 3 else {
      print("Could not initialize fraternity component: house key (invalid entry = \(key))")
      return nil
    }
    guard let name = dict[Database.keys.frat.name] as? String else {
      print("Could not initialize fraternity component: house name (key = \(key))")
      return nil
    }
    guard let description = dict[Database.keys.frat.description] as? String else {
      print("Could not initialize \(name)'s description")
      return nil
    }
    guard let chapter = dict[Database.keys.frat.chapter] as? String else {
      print("Could not initialize \(name)'s chapter")
      return nil
    }
    guard let memberCountRaw = dict[Database.keys.frat.memberCount] as? String else {
      print("Could not initialize \(name)'s member count (raw)")
      return nil
    }
    guard let memberCount = Int(memberCountRaw) else {
      print("Could not initialize \(name)'s member count (\(memberCountRaw))")
      return nil
    }
    
    
    var cImagePath : RMImageFilePath?
    if let calendarImagePathRaw = dict[Database.keys.frat.calendarImage] as? String {
      cImagePath = RMImageFilePath(filename: calendarImagePathRaw)
    }
    
    var coImagePaths = [RMImageFilePath]()
    if let coverImagePathRaw = dict[Database.keys.frat.coverImage] as? String {
      let path = RMImageFilePath(filename: coverImagePathRaw)
      coImagePaths.append(path)
    }
    
    let pImagePath = RMImageFilePath(filename: key + "prof")
    
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
