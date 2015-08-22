//
//  APIClient.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import Alamofire
import ObjectMapper
import Result

typealias CallbackType = ((Result<AnyObject, NSError>) -> Void)

class APIClient {
    
    static let sharedClient = APIClient()
    
    private let domain = "https://intense-lake-9534.herokuapp.com"
    
    func timeline(callback:(Result<Timeline, NSError>)->()) {
        Alamofire
            .request(.GET, self.createUrl("list"))
            .responseJSON { (request, response, JSON, error) in
                if let error = error {
                    callback(Result(error: error))
                }
                if let JSON = JSON {
                    callback(Result(value: Mapper<Timeline>().map(JSON)!))
                }
            }
    }

    func upload(audio:AnyObject, callback:CallbackType) {
        Alamofire
            .request(.POST, self.createUrl("upload"))
            .responseJSON { (request, response, JSON, error) in
                if let error = error {
                    callback(Result(error: error))
                } else {
                    callback(Result(value: JSON!))
                }
        }
    }
    
    func download(path: String, callback:CallbackType) {
        Alamofire
            .request(.GET, self.createUrl("converted/" + path))
            .responseJSON { (request, response, JSON, error) in
                if let error = error {
                    callback(Result(error: error))
                } else {
                    callback(Result(value: JSON!))
                }
        }
    }
    
    // MARK: - Private
    
    private func createUrl(subPath: String) -> String {
        return join("/", [domain, subPath])
    }
    
}