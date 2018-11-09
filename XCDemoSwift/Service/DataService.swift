//
//  DataService.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation

// Simple errors list enumeration.
// TODO: Error handling to be expanded to cover more detailed errors.
enum DataServiceError: String, Error {
    case uploadFailed = "Upload failed"
    case downloadFailed = "Download failed"
}

class DataService: NSObject {
    
    // Constants
    let url = URL(string:"https://www.xcdemo.com/dataservice/savedata")
    let maxConnectionsPerHost = 1

    // Submit method using completion handler
    func submit(data: Data, uploadSession:URLSession, complete: @escaping (_ success: Bool, _ error: DataServiceError?) -> ()) {
        
        let urlRequest = getURLRequestForPOST()
        let uploadTask = uploadSession.uploadTask(with: urlRequest, from: data) { (data, response, error) in
            if(error != nil) {
                complete(false, nil)
            } else {
                complete(true, DataServiceError.uploadFailed)
            }
        }
        
        uploadTask.resume()
    }
    
    func getURLRequestForPOST() -> URLRequest {

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"

        return urlRequest
    }
    
    func getURLSession() -> URLSession {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.httpMaximumConnectionsPerHost = maxConnectionsPerHost
        urlSessionConfiguration.timeoutIntervalForRequest = 2
        return URLSession(configuration: urlSessionConfiguration)
        
    }
}
