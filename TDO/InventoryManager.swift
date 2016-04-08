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
    var id = 0
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
        self.clearData()
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
                //add an item saying the connection is broken
                self.addItem("No connection", desc: "", id: -1)
                self.dataLoaded = true
                return
            }
            //get the HTTPStatus
            let httpStatus = response as? NSHTTPURLResponse
            print(httpStatus?.statusCode)
            //if it's wrong
            if  httpStatus?.statusCode == 420 { // check for http
                let responseString = String(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
                print(responseString)
                let csv = CSwiftV(String: responseString)
                print(csv.headers)
                //add the headers as new items
                for item in csv.headers {
                    self.addItem(item, desc: "", id: 0)
                }
                //set data to be reloaded
                self.dataLoaded = true
            }else{
                //add new item to say it failed
                self.addItem("Data failed to load", desc: "", id: -1)
                self.dataLoaded = true
            }
        }
        //resume the task
        task.resume()
    }
    
    func addItem(name: String, desc: String, id: Int){
        items.append(Item(id: id, name: name, desc: desc));
    }
    
    func clearData(){
        dataLoaded = false
        items.removeAll()
    }
}
