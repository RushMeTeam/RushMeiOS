//
//  Images.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/23/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation


class RMCachedImage {
  static var images = Dictionary<String, UIImage>()
}
extension UIImageView {
  func setImageByURL(fromSource sourceString : String, animated: Bool = true) {
    func setAsync(image newImage : UIImage) {
      _ = RMCachedImage.images[sourceString] == nil ? {
        RMCachedImage.images[sourceString] = newImage
        } : nil
      DispatchQueue.main.async {
        if self.image == nil {
          self.image = newImage
        }
      }
    }
    let rmURL = RMurl(fromString: sourceString)
    DispatchQueue.global(qos: .userInteractive).async {
      if let newImage = RMCachedImage.images[sourceString] {
        DispatchQueue.main.async {
          self.image = newImage
        }
      }
      else if let image = readImageFromDisk(at: rmURL) {
        setAsync(image: image)
      }
      else {
        DispatchQueue.main.async {
          self.image = nil
        }
        URLSession.shared.dataTask(with: rmURL.networkPath) {
          (data, _, error) in
          DispatchQueue.main.async {
            if data != nil, let newImage = UIImage(data: data!) {
              newImage.storeOnDisk(at: rmURL.localPath)
              setAsync(image: newImage)
            }
            else {
              SQLHandler.inform(action: .SQLError, options: error?.localizedDescription) 
            }
          }
          }.resume()
      }
    }
  }
}


func readImageFromDisk(at sourceURL : RMurl, with : Quality = Campus.downloadedImageQuality) -> UIImage? {
  if let imageData = try? Data.init(contentsOf: sourceURL.localPath),
    let image = UIImage.init(data: imageData){
    return image
  }
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
