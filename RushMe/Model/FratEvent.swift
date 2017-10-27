//
//  FratEvent.swift
//  RushMe
//
//  Created by James Hines on 10/21/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import Foundation
    //NStime and NSdate
    //SQL format
    //(‘name’, ’event’, ‘start’, ‘end’, ‘date’, ‘location’),
    //let previewImage : UIImage
    //  var memberCount : Int? = nil
class FratEvent: NSObject {
    let fratName : String
    let eventName : String
    let startTime : NSDate?
    let endTime : NSDate?
    let eventLocation : String?
    
    init(fratName : String, eventName : String, startTime : NSDate?, endTime : NSDate?, eventLocation : String? ) {
        self.fratName = fratName
        self.eventName = eventName
//        if let startTime = startTime {
//            self.startTime = startTime
//        }
//        else {
//            self.startTime =
//        }
        
    }
    
}
