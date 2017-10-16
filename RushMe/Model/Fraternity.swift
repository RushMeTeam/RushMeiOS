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
  let name : String
  let chapter : String
  let previewImage : UIImage
//  var memberCount : Int? = nil
//  var desc : String? = nil
//  var coverPhoto : UIImage? = nil
//  var profilePhoto : UIImage? = nil
//  var previewPhoto : UIImage? = nil
  
  private var properties : Dictionary<String, Any>
  // NOTE: PreviewImage will NOT be NULL in future iterations of this app
  init(name : String, chapter : String, previewImage: UIImage?, properties : Dictionary<String, Any>? = nil) {
    self.name = name
    self.chapter = chapter
    if let previewImg = previewImage {
      self.previewImage = previewImg
    }
    else {
      self.previewImage = IMAGE_CONST.NO_IMAGE
    }
    if let prop = properties {
      self.properties = prop
    }
    else {
      self.properties = Dictionary<String, Any>()
    }
    
  }
  
  func getProperty(named : String) -> Any? {
    if (named == "name"){ return self.name }
    if (named == "chapter"){ return self.chapter }
    if (named == "previewImage"){ return self.previewImage }
    return properties[named]
  }
  func setProperty(named : String, to : Any){
    properties[named] = to
  }
}

