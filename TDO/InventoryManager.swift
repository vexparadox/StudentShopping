//
//  InventoryManager.swift
//  TDO
//
//  Created by William Meaton on 02/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

var invManager: InventoryManager = InventoryManager()

struct Item {
    var name = "Un-named"
    var desc = "Undescribed"
}

struct List{
    var name = "Un-named"
}

class InventoryManager: NSObject {
    var items = [Item]()
    var dataLoaded : Bool = false
    func getData(){
        let prefs = NSUserDefaults.standardUserDefaults()
        let loggedname = prefs.valueForKey("username")
        let request = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/data.php")!)
        request.HTTPMethod = "POST"
        //pass the username and password
        let postString = "username="+loggedname!.description
        //new request
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        //create a task thread
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check forfundamental networking error
                print("error=\(error)")
                self.dataLoaded = true
                return
            }
            //get the HTTPStatus
            let httpStatus = response as? NSHTTPURLResponse
            print(httpStatus?.statusCode)
            //if it's wrong
            if  httpStatus?.statusCode != 420 { // check for http
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                self.dataLoaded = true
            }
        }
        //resume the task
        task.resume()
    }
    
    func addItem(name: String, desc: String){
        items.append(Item(name: name, desc: desc));
    }
}
