//
//  UrlRequestBuffer.swift
//  Raven-Swift
//
//  Created by Joshua Fisher on 3/31/16.
//  Copyright © 2016 OKB. All rights reserved.
//

import Foundation
import Raven

class UrlRequestBuffer {
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private var requestBuffer: [NSURLRequest] = []
    private let internalQueue = dispatch_queue_create("co.calendre.sentry-request-flush-queue", DISPATCH_QUEUE_SERIAL)
    
    func addRequest(request: NSURLRequest) {
        dispatch_async(internalQueue) {
            self.requestBuffer.append(request)
        }
    }
    
    func flushBuffer(withCompetionHandler completionHandler: () -> Void) {
        dispatch_async(internalQueue) {
            // grab all the requests
            let requests = self.cycleRequestBuffer()
            
            // use dispatch group to wait for all the tasks to complete
            let group = dispatch_group_create()
            
            // fire up tasks for all pending requests
            for request in requests {
                let task = self.session.dataTaskWithRequest(request) { (_, response, error) in
                    dispatch_group_leave(group)
                    
                    if let error = error {
                        let userInfo = error.userInfo as! [String: AnyObject]
                        let errorKey: AnyObject? = userInfo[NSURLErrorFailingURLStringErrorKey]
                        print("Connection failed! Error - \(error.localizedDescription) \(errorKey!)")
                        
                    } else if let response = response {
                        #if DEBUG
                            print("Response from Sentry: \(response)")
                        #endif
                    }
                    print("JSON sent to Sentry")
                }
                dispatch_group_enter(group)
                task.resume()
            }
            
            // wait for all the requests to finish
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            completionHandler()
        }
    }
    
    private func cycleRequestBuffer() -> [NSURLRequest] {
        let copy = requestBuffer
        requestBuffer = []
        return copy
    }
}

extension UrlRequestBuffer: RavenClientTransportDelegate {
    func ravenClient(client: RavenClient, producedRequest request: NSURLRequest) {
        addRequest(request)
    }
}
