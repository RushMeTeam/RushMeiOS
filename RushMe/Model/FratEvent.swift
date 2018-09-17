//
//  FratEvent.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class Fraternity.Event {
  
}
// Make a date, such as Sunday, November 22nd, 12:00PM return its time, as a string, i.e. "12:00PM"
// An extension to Date that empowers the FratEvent class.
extension Date {
  func formatToHour() -> String {
    let time = DateFormatter.localizedString(from: self,
                                             dateStyle: DateFormatter.Style.none,
                                             timeStyle: DateFormatter.Style.full)
    let AmPm = String(time.split(separator: " ")[1])
    let split = time.split(separator: ":")
    let hour = String(split[0])
    let min = String(split[1])
    return hour + ":" +  min + " " + AmPm
    
  }
  
}
