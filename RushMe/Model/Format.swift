//
//  Date.swift
//  RushMe
//
//  Created by Adam Kuniholm on 9/17/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation

struct Format {
  // String formatting
  struct dates {
    // How to format a Date, e.g. 10th Sept, 2018 --> 09/10/18
    static let dateFormatter : DateFormatter = {
      let dF = DateFormatter()
      dF.isLenient = true
      dF.dateFormat =  "MM/dd/yyyy"
      dF.formatterBehavior = .default
      dF.locale = Locale.current
      return dF
    }()
    // How to format a DateTime, e.g. 11 PM 10th Sept, 2018 --> 09/10/18 23:00
    static let dateTimeFormatter : DateFormatter = {
      let dTF = DateFormatter()
      dTF.dateFormat = "MM/dd/yyyy hh:mm"
      dTF.isLenient = true
      dTF.locale = Locale.current
      dTF.formatterBehavior = .default
      return dTF
    }()
    // How to format a Date/DateTime for the Database
//    static let defaultSQLDateFormatter : DateFormatter = {
//      let dF = DateFormatter()
//      dF.isLenient = true
//      dF.dateFormat = "yyyy-MM-dd"
//      dF.formatterBehavior = .default
//      dF.locale = Locale.current
//      return dF
//    }()
    private static var SQLDateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
    static var SQLDateFormatter : DateFormatter {
      get {
        let formatter = DateFormatter()
        formatter.dateFormat = SQLDateFormat
        return formatter
      }
    }
    static func date(fromSQLDateTime inputString: String) -> Date? {
      return self.dateFormatter.date(from: inputString)
    }
  }
}
