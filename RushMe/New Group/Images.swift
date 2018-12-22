//
//  Images.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/23/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

// Describe three quality metrics
enum ImageQuality : String {
  case High = "small.jpg"
  case Medium = "semi.jpg"
  case Low = ".jpg"
}

extension UIImageView {
  func setImage(with rmURL: RMImageFilePath, onNewThread : Bool = true) {
    if (onNewThread) {
      self.image = nil
      DispatchQueue.global(qos: .userInitiated).async {
        self.setImage(with: rmURL,onNewThread: false)
      }
      return
    }
    func setOnlyIfNull(newImage : UIImage) {
      DispatchQueue.main.async { 
        if self.image == nil { self.image = newImage } 
      }
    }
    func handleDownloadedImage(imageData : Data?) {
      if let _ = imageData, let newImage = UIImage(data: imageData!) {
        setOnlyIfNull(newImage: newImage) 
        newImage.writeToDisk(at: rmURL.localPath)
        UIImage.cache[rmURL] = newImage
      }
    }
    
    // Read from cache
    if let image = UIImage.cache[rmURL] {
      setOnlyIfNull(newImage : image)
    }
      // Read from disk, cache 
    else if let image = UIImage(contentsOf: rmURL) {
      setOnlyIfNull(newImage : image) 
    }
    // Download, write to disk, cache
    else {
      URLSession.shared.dataTask(with: rmURL.networkPath) {
        (data, _, error) in
        handleDownloadedImage(imageData: data)
        if let _ = error {
         Backend.log(action: .Error(type: .Download)) 
        }
      }.resume()
    }
  }
}

extension UIImage {
  internal static var cache = Dictionary<RMImageFilePath, UIImage>()
  
  convenience init?(contentsOf path : RMImageFilePath) {
    if let imageData = try? Data.init(contentsOf: path.localPath) {
      self.init(data: imageData)
    }
    else {
     return nil 
    }
  }
  func writeToDisk(at url : URL) {
    if !FileManager.default.fileExists(atPath: User.files.fratImageURL.path) {
      do {
        try FileManager.default.createDirectory(at: User.files.fratImageURL, withIntermediateDirectories: false, attributes: nil)
      }
      catch let e {
        print(e.localizedDescription)
      }
    }
    if let imageData = self.pngData() {
      do {
        try imageData.write(to: url)
      }
      catch let e {
        print("StoreOnDisk Error:", e.localizedDescription)
      }
    }
  }
}

class RMFilePath : Hashable {
  var filename : String
  init(filename : String) {
    self.filename = filename 
  }
  var localPath : URL {
    return User.files.Path.appendingPathComponent(filename)
  }
  var networkPath : URL {
    return URL(string: Backend.S3 + filename)!
  }
  var hashValue : Int {
    return filename.hashValue
  }
  static func == (lhs: RMFilePath, rhs: RMFilePath) -> Bool {
    return lhs.filename == rhs.filename
  }
  
}


class RMImageFilePath : RMFilePath {
  init(filename : String, quality : ImageQuality = Campus.downloadedImageQuality) {
    super.init(filename: filename + quality.rawValue)
  }
  
  override var localPath : URL {
    return User.files.fratImageURL.appendingPathComponent(filename)
  }
//  static func urlSuffix(filename : String, quality : ImageQuality = Campus.downloadedImageQuality) -> String {
//    // Images are scaled to three different sizes:
//    //    - high (i.e. full)
//    //    - medium (i.e. half-size)
//    //    - low (i.e. quarter-size)
//    // The quality of the image retreived is based on the
//    // file URL. For example, a file named "image.jpg" would
//    // have a half-sized image named "imagesemi.jpg"
//    switch quality {
//    case .High:
//      // Frat_Info_Pics/Sigma_Delta_Cover_Image.png
//      return filename + ImagePathSuffix.lowQuality
//    case.Medium:
//      // Frat_Info_Pics/Sigma_Delta_Cover_Image_half.png
//      return filename + ImagePathSuffix.mediumQuality
//    case.Low:
//      // Frat_Info_Pics/Sigma_Delta_Cover_Image_quarter.png
//      return filename + ImagePathSuffix.lowQuality
//    }
//    // Sigma_Delta_Cover_Image.png
//    
//    // .../local/on/device/path/Sigma_Delta_Cover_Image.png
//    //return filename
//  }
//  
//  static func urlSuffixes(forImageFilename filename : String) -> (String, String, String) {
//    return (low : urlSuffix(filename: filename, quality: .Low), 
//            medium: urlSuffix(filename: filename, quality: .Medium), 
//            high: urlSuffix(filename: filename, quality: .High))
//  }
}

// TODO: Implement a useful Image class. Difficult because app is event-driven 
//          and displaying images sourced from the network
//class Image {
//  var lowQuality : UIImage? {
//    get {
//      return nil 
//    }
//    set {
//      
//    }
//  }
//  var mediumQuality : UIImage? {
//    get {
//      return nil 
//    }
//    set {
//      
//    }
//  }
//  var highQuality : UIImage? {
//    get {
//      return nil 
//    }
//    set {
//      
//    }
//  }
//  let path : RMURL
//  required init?(path : String) {
//    if let url = RMURL.init(fromString: path) {
//      self.path = url
//    } else {
//      return nil
//    }
//    
//  }
//  
//}
