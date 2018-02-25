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
        for postDict in postDictArray {
          if let postId = postDict["postid"] as? Int, let title = postDict["title"] as? String,
            let dateTimeString = postDict["posttime"] as? String,
            // TODO: FIX DOWNCAST!!!
            let postDate = RMDatabaseFormat.date(fromSQLDateTime: dateTimeString),
            let optionsDictArray = SQLHandler.shared.select(fromTable: "postoptions", conditions: "postid = \(postId)" ){
            print(postId, title)
            for option in optionsDictArray {
             print("\t\(option["postoption"]!)")
            }
            
          }
        }
      }
      var foundPosts = [RMPost]()
      
      return foundPosts
      
    }
  }

}

