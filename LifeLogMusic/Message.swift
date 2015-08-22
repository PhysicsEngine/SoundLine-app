//
//  Message.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import ObjectMapper

class Message : Mappable {
    
    var userName = ""
    var fileName = ""
    
    class func newInstance(map: Map) -> Mappable? {
        return Message()
    }
    
    func mapping(map: Map) {
        userName <- map["user"]
        fileName <- map["fileName"]
    }
    
}