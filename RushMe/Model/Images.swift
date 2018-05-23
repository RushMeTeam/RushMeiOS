//
//  Images.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/23/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation

extension UIImageView {
  func setImageByURL(fromSource sourceString : String, animated: Bool = true) {
    layer.drawsAsynchronously = true
    image = nil
    DispatchQueue.global(qos: .userInteractive).async {
      let image = pullImage(fromSource: RMurl(fromString: sourceString), fallBackToNetwork: true)
      DispatchQueue.main.async {
        UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: {
          self.image = image
        }, completion: nil)
      }
    }
  }
}


func pullImage(fromSource sourceURL : RMurl, quality : Quality = Campus.downloadedImageQuality, fallBackToNetwork : Bool = false) -> UIImage? {
  if let imageData = try? Data.init(contentsOf: sourceURL.localPath),
    let image = UIImage.init(data: imageData){
    return image
  }
  else if !fallBackToNetwork {
    return nil
  }
  // Try to retreive the image-- upon fail return nil
  if let data = try? Data.init(contentsOf: sourceURL.networkPath) {
    // Try to downcase the retreived data to an image
    if let image = UIImage(data: data) {
      DispatchQueue.global(qos: .background).async {
        image.storeOnDisk(at: sourceURL.localPath)
      }
      return image
    }
  }
  // May be nil!
  return nil
}

extension UIImage {
  func storeOnDisk(at url : URL) {
    if !FileManager.default.fileExists(atPath: RMFileManagement.fratImageURL.path) {
      do {
        try FileManager.default.createDirectory(at: RMFileManagement.fratImageURL, withIntermediateDirectories: false, attributes: nil)
      }
      catch let e {
        print(e.localizedDescription)
      }
    }
    if let imageData = UIImagePNGRepresentation(self) {
      do {
        try imageData.write(to: url)
      }
      catch let e {
        print("StoreOnDisk Error:", e.localizedDescription)
      }
    }
  }
}
