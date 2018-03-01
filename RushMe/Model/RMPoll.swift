//
//  RMPoll.swift
//  RushMe
//
//  Created by Adam Kuniholm on 2/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation


class RMPost {
  let title : String
  let postDate : Date
  let author : String
  init(author : String, title : String, postDate : Date) {
    self.author = author
    self.title = title
    self.postDate = postDate
  }
}



class RMPoll : RMPost {
  let options : [String]
  init(author : String, title : String, postDate : Date, options : [String]) {
    self.options = options
    super.init(author: author, title: title, postDate: postDate)
  }
  
}


extension Fraternity {
  var posts : [RMPost] {
    get {
      
      if let postDictArray = SQLHandler.shared.select(fromTable: "feedposts", conditions: "author = '\(name)'") {
        var foundPosts = [RMPost]()
        for postDict in postDictArray {
          if let postId = postDict["postid"] as? Int, 
            let title = postDict["title"] as? String,
            let author = postDict["author"] as? String,
            let timeInterval = postDict["posttime"] as? TimeInterval,
            let optionsDictArray = SQLHandler.shared.select(fromTable: "postoptions", conditions: "postid = \(postId)" ){
            let postDate = Date(timeIntervalSinceReferenceDate: timeInterval)
            var options = [String]()
            for option in optionsDictArray {
              options.append(option["postoption"] as! String)
            }
            if options.isEmpty {
             foundPosts.append(RMPost.init(author: author, title: title, postDate: postDate)) 
            }
            else {
             foundPosts.append(RMPoll.init(author: author, title: title, postDate: postDate, options: options)) 
            }
          }
        }
        return foundPosts
      }
      
      
      return [RMPost]()
      
    }
  }

}

