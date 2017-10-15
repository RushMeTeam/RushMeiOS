//
//  Fraternity.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit
class Fraternity : NSObject {
  var memberCount : Int? = nil
  var name : String? = nil
  var chapter : String? = nil
  var desc : String? = nil
  var coverPhoto : UIImage? = nil
  var profilePhoto : UIImage? = nil
  var previewPhoto : UIImage? = nil
  init(name : String?, chapter : String?, description : String?,
       imageNames : Dictionary<String, String>?) {
    self.name = name
    self.chapter = chapter
    self.desc = description
    if let dict = imageNames {
      if let profileName = dict["profile"] {
        profilePhoto = UIImage(named: profileName)
      }
      if let coverName = dict["cover"] {
        coverPhoto = UIImage(named: coverName)
      }
      
      if let previewName = dict["preview"] {
        previewPhoto = UIImage(named: previewName)
      }
      else {
        previewPhoto = profilePhoto
      }
    }
  }
}
func convertToGreek(aString : String) -> String {
  return ""
}
