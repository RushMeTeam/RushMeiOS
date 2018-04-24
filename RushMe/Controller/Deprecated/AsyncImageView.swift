//
//  AsyncImageView.swift
//  RushMe
//
//  Created by Adam Kuniholm on 4/19/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class AsyncImageView: UIImageView, URLSessionDownloadDelegate, URLSessionTaskDelegate {
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  private lazy var animatedGradient = AnimatableGradientLayer()
  var url : URL! {
    didSet {
      
    }
  }
  private(set) var dataTask : URLSessionDataTask!
  private(set) lazy var configuration : URLSessionConfiguration = {
    let config = URLSessionConfiguration.default
    //config.timeoutIntervalForRequest = 5
    
    return config
  }()
  private(set) lazy var urlSession = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
  convenience init(frame : CGRect, url : URL) {
    self.init(frame: frame)
    self.url = url
  }
  required override init(frame : CGRect) {
    super.init(frame: frame) 
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
    print("Waiting")
  }
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    print("finished")
  }
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print("ooh")
    
  }
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    print("Progress:", Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
    if #available(iOS 11.0, *) {
      print("Also progress", downloadTask.progress)
    } else {
      // Fallback on earlier versions
    }
  }
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    print(error?.localizedDescription)
  }
  deinit {
    //dataTask.cancel()
  }
    
    //    do {
    //      let documentsURL = try
    //        FileManager.default.url(for: .documentDirectory,
    //                                in: .userDomainMask,
    //                                appropriateFor: nil,
    //                                create: false)
    //      let savedURL = documentsURL.appendingPathComponent(
    //        location.lastPathComponent)
    //      try FileManager.default.moveItem(at: location, to: savedURL)
    //    } catch {
    //      print ("file error: \(error)")
    //    }
  /*
   
   
   if !FileManager.default.fileExists(atPath: RMFileManagement.fratImageURL.path) {
   do {
   try FileManager.default.createDirectory(at: RMFileManagement.fratImageURL, withIntermediateDirectories: false, attributes: nil)
   }
   catch let e {
   print(e.localizedDescription)
   }
   }
   let fixedPath = urlSuffix(forFileWithName: fromSource, quality : quality)
   let urlEnding = String(fixedPath.split(separator: "/").last!)
   let localFileURL = RMFileManagement.fratImageURL.appendingPathComponent(urlEnding)
   
   //if (DEBUG) { print(fileName, separator: "", terminator: "") }
   let urlAsString = RMNetwork.HTTP + fixedPath
   var image : UIImage? = nil
   // Try to create an URL from the string-- upon fail return nil
   if let url = URL(string: urlAsString) {
   //if (DEBUG) { print(".", separator: "", terminator: "") }
   // Try to retreive the image-- upon fail return nil
   let config = URLSessionConfiguration.background(withIdentifier: "RushMe")
   config.timeoutIntervalForRequest = 5
   
   let _ = URLSession.init(configuration: config, delegate: completionDelegate, delegateQueue: nil).dataTask(with: url)
   
   //    _ = session.dataTask(with: url) { (data, response, error) in
   //      if let _ = error {
   //        print(error!.localizedDescription)
   //        DispatchQueue.global(qos: .background).async {
   //        completionHandler(nil, error)
   //        }
   //      }
   //      if let _ = data, let image = UIImage.init(data: data!) {
   //        completionHandler(image, nil)
   //        DispatchQueue.global(qos: .background).async {
   //        do {
   //          try UIImagePNGRepresentation(image)?.write(to: localFileURL)
   //        }
   //        catch let e {
   //          print(e.localizedDescription)
   //        }
   //        }
   //        return
   //        }
   //      
   //      }.resume()
   
   
   
   if let data = try? Data.init(contentsOf: url){
   //if (DEBUG) { print(".", separator: "", terminator: "") }
   // Try to downcase the retreived data to an image
   if let img = UIImage(data: data) {
   image = img
   
   //if (DEBUG) { print(".Done", separator: "", terminator: "") }
   }
   }
   }
   }
   */
}
