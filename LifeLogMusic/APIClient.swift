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
    
    //private let domain = "https://intense-lake-9534.herokuapp.com"
    private let domain = "http://172.16.200.132:5000"
    
    func timeline(callback:(Result<Timeline, NSError>)->()) {
        Alamofire
            .request(.GET, self.createUrl("list"))
            .responseJSON { (request, response, JSON, error) in
                if let error = error {
                    return callback(Result(error: error))
                }
                if let JSON = JSON {
                    return callback(Result(value: Mapper<Timeline>().map(JSON)!))
                }
            }
    }

    func upload(audio:NSData, callback:(Result<AnyObject?, NSError>)->()) {
        Alamofire
        .upload(.POST, URLString: self.createUrl("upload"), headers: nil, multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: "gologo".dataUsingEncoding(NSUTF8StringEncoding)!, name: "username")
            multipartFormData.appendBodyPart(data: audio, name: "file", fileName: "unko.m4a", mimeType: "video/m4a")
            },
            encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.response { request, response, data, error in
                        println("request body: \(request.HTTPBody)")
                        if let error = error {
                            return callback(Result(error: error))
                        }
                        return callback(Result(value: nil))
                    }
                case .Failure(let encodingError):
                    println(encodingError)
                }
            }
        )
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