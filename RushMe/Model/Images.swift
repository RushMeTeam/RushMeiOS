//
//  Images.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/23/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit




struct ImagePathSuffix {
  static let lowQuality = ""
  static let mediumQuality = "_Half.png.png"
  static let highQuality = "_Quarter.png.png"
}


class RMCachedImage {
  static var images = Dictionary<String, UIImage>()
}
extension UIImageView {
  func setImageByURL(fromSource rmURL : RMURL, animated: Bool = true) {
    func setAsync(image newImage : UIImage) {
      _ = RMCachedImage.images[rmURL.underlyingURL.absoluteString] == nil ? {
        RMCachedImage.images[rmURL.underlyingURL.absoluteString] = newImage
        } : nil
      DispatchQueue.main.async {
        if self.image == nil {
          self.image = newImage
        }
      }
    }
    DispatchQueue.main.async {
      self.image = nil
    }
    DispatchQueue.global(qos: .userInteractive).async {
      if let newImage = RMCachedImage.images[rmURL.underlyingURL.absoluteString] {
        DispatchQueue.main.async {
          self.image = newImage
        }
      }
      else if let image = readImageFromDisk(at: rmURL) {
        setAsync(image: image)
      }
      else {
        URLSession.shared.dataTask(with: rmURL.networkPath) {
          (data, _, error) in
          DispatchQueue.main.async {
            if data != nil, let newImage = UIImage(data: data!) {
              newImage.storeOnDisk(at: rmURL.localPath)
              setAsync(image: newImage)
            }
            else {
              Backend.log(action: .SQLError, options: error?.localizedDescription) 
            }
          }
          }.resume()
      }
    }
  }
}


func readImageFromDisk(at sourceURL : RMURL, with : Quality = Campus.downloadedImageQuality) -> UIImage? {
  if let imageData = try? Data.init(contentsOf: sourceURL.localPath),
    let image = UIImage.init(data: imageData){
    return image
  }
  return nil
}

extension UIImage {
  func storeOnDisk(at url : URL) {
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

struct RMURL : Hashable {
  let underlyingURL : URL
  init?(fromString : String) {
    if let newURL = URL.init(string: fromString) {
      self.underlyingURL = newURL 
    }
    else {
      return nil 
    }
  }
  static func urlSuffix(forFileWithName urlSuffix : String, quality : Quality = Campus.downloadedImageQuality) -> String {
    var fileName = ""
    // Images are scaled to three different sizes:
    //    - high (i.e. full)
    //    - medium (i.e. half-size)
    //    - low (i.e. quarter-size)
    // The quality of the image retreived is based on the
    // file URL. For example, a file named "image.png" would
    // have a half-sized image named "image_Half.png"
    switch quality {
    case .High:
      // Frat_Info_Pics/Sigma_Delta_Cover_Image.png
      fileName = urlSuffix + ImagePathSuffix.lowQuality
    case.Medium:
      // Frat_Info_Pics/Sigma_Delta_Cover_Image_half.png
      fileName = urlSuffix.dropLast(4) + ImagePathSuffix.mediumQuality
    case.Low:
      // Frat_Info_Pics/Sigma_Delta_Cover_Image_quarter.png
      fileName = urlSuffix.dropLast(4) + ImagePathSuffix.lowQuality
    }
    // Sigma_Delta_Cover_Image.png
    
    // .../local/on/device/path/Sigma_Delta_Cover_Image.png
    return fileName
  }
  static func urlSuffixes(forFilesWithName filename : String) -> [String] {
    return [urlSuffix(forFileWithName: filename, quality: .Low), urlSuffix(forFileWithName: filename, quality: .Medium), urlSuffix(forFileWithName: filename, quality: .High)]
  }
  init(_ fromURL : URL) {
    self.underlyingURL = fromURL
  }
  private var fixedPath : String {
    return RMURL.urlSuffix(forFileWithName: underlyingURL.absoluteString,quality : Campus.downloadedImageQuality)
  }
  var localPath : URL {
    let urlEnding = String(fixedPath.split(separator: "/").last!)
    return User.files.fratImageURL.appendingPathComponent(urlEnding)
  }
  var networkPath : URL {
    
    return URL(string: Backend.S3.absoluteString + fixedPath)!
  }
  var hashValue : Int {
    return underlyingURL.hashValue
  }
}

// TODO: Implement a useful Image class. Difficult because App is Event-driven
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
