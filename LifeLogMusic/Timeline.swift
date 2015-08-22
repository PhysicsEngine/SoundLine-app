//
//  Timeline.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import ObjectMapper

class Timeline : Mappable {
    
    var users = [Message]()
    
    static func newInstance(map: Map) -> Mappable? {
        return Timeline()
    }
    
    func mapping(map: Map) {
        users <- map["users"]
    }
}