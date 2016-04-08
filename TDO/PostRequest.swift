//
//  PostRequest.swift
//  TDO
//
//  Created by William Meaton on 08/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import Foundation

class PostRequest{
    var url, postString : String
    var isComplete : Bool = false
    var responseCode : Int = 0
    var responseString : String = ""
    init(url: String, postString: String){
        self.url = url
        self.postString = postString
        start()
    }
    
    func start(){
        isComplete = false
        responseCode = 0
        responseString = ""
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                //the code is broke
                self.responseCode = -1
                //print the error
                print("error=\(error)")
                self.isComplete = true
                return
            }
            let httpStatus = response as? NSHTTPURLResponse
            if  httpStatus?.statusCode != 0 {           // check for http
                //get any data returned
                self.responseString = String(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
                //get the response code
                self.responseCode = (httpStatus?.statusCode)!
                //it's complete
                self.isComplete = true
            }
        }
        task.resume()
        //wait for completion
        while(!isComplete){}
    }
}