//
//  Fraternity.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit
import os.log
class Fraternity : NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: FRAT_KEYS.NAME)
        aCoder.encode(chapter, forKey: FRAT_KEYS.CHAPTER)
        aCoder.encode(previewImage, forKey: FRAT_KEYS.PREVIEW_IMAGE)
        aCoder.encode(NSDictionary(dictionary: properties), forKey: FRAT_KEYS.PROPERTIES)
      
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: FRAT_KEYS.NAME) as? String else {
            os_log("Unable to decode the name for the frat object", log: OSLog.default, type: .debug)
            return nil
        }
        guard let chapter = aDecoder.decodeObject(forKey: FRAT_KEYS.CHAPTER) as? String else {
            os_log("Unable to decode the chapter for the frat object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let previewImage = aDecoder.decodeObject(forKey: FRAT_KEYS.PREVIEW_IMAGE) as? UIImage else {
            os_log("Unable to decode the preview image for the frat object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let properties = aDecoder.decodeObject(forKey: FRAT_KEYS.PROPERTIES) as? NSDictionary else {
            os_log("Unable to decode the properties for the frat object.", log: OSLog.default, type: .debug)
            return nil
        }
        let realProperties = properties as! Dictionary<String, Any>
        self.init(name: name, chapter: chapter, previewImage: previewImage, properties: realProperties)
    }
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("fraternities")
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
    self.properties["profileImage"] = previewImage
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
// A not-so-genius way to create greek representations of frat names
func greekLetters(inString : String) -> String {
  var result = inString.replacingOccurrences(of: "Alpha", with: "Α")
  result = result.replacingOccurrences(of: "Beta", with: "Β")
  result = result.replacingOccurrences(of: "Gamma", with: "Γ")
  result = result.replacingOccurrences(of: "Delta", with: "Δ")
  result = result.replacingOccurrences(of: "Epsilon", with: "Ε")
  result = result.replacingOccurrences(of: "Zeta", with: "Ζ")
  result = result.replacingOccurrences(of: "Eta", with: "Η")
  result = result.replacingOccurrences(of: "Theta", with: "Θ")
  result = result.replacingOccurrences(of: "Iota", with: "Ι")
  result = result.replacingOccurrences(of: "Kappa", with: "Κ")
  result = result.replacingOccurrences(of: "Lambda", with: "Λ")
  result = result.replacingOccurrences(of: "Mu", with: "Μ")
  result = result.replacingOccurrences(of: "Nu", with: "Ν")
  result = result.replacingOccurrences(of: "Xi", with: "Ξ")
  result = result.replacingOccurrences(of: "Omicron", with: "Ο")
  result = result.replacingOccurrences(of: "Pi", with: "Π")
  result = result.replacingOccurrences(of: "Rho", with: "Ρ")
  result = result.replacingOccurrences(of: "Sigma", with: "Σ")
  result = result.replacingOccurrences(of: "Tau", with: "Τ")
  result = result.replacingOccurrences(of: "Upsilon", with: "Υ")
  result = result.replacingOccurrences(of: "Phi", with: "Φ")
  result = result.replacingOccurrences(of: "Chi", with: "Χ")
  result = result.replacingOccurrences(of: "Psi", with: "Ψ")
  result = result.replacingOccurrences(of: "Omega", with: "Ω")
  return result
}

