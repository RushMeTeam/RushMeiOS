//
//  Observable.swift
//  RushMe
//
//  Created by Adam Kuniholm on 4/2/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
// Make sure Observable for Hashable only, then use dictionary?? O(1)
class Observable<ValueType> {
  typealias ChangeHandler = (_ oldValue : ValueType?, _ newValue : ValueType) -> ()
  var value : ValueType {
    willSet {
      DispatchQueue.global(qos: .utility).async {
        for (_, handlers) in self.observers {
          for handler in handlers {
            DispatchQueue.main.async {
              handler(self.value, newValue) 
            }
          }
        }
      }
    }
  }
  private var observers : [(owner : AnyObject, handlers : [ChangeHandler])] = []
  init (_ value : ValueType) {
    self.value = value
  }
  func index(ofOwner owner : AnyObject) -> Int? {
    var index : Int = 0
    for (possibleOwner, _) in observers {
      if possibleOwner === owner {
       return index 
      }
      index += 1
    }
    return nil
  }
  
  func addObserver(forOwner owner : AnyObject, handler : @escaping ChangeHandler) {
    if let index = self.index(ofOwner: owner) {
     self.observers[index].handlers.append(handler) 
    }
    else {
      self.observers.append((owner: owner, handlers: [handler]))
    }
  }
  
}
