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
    var id = -1
    var household = -1
    var name = "Un-named"
    var desc = "Undescribed"
}

class InventoryManager: NSObject {
    var items = [Item]()
    var dataLoaded : Bool = false
    
    func getData(){
        self.clearData()
        let prefs = NSUserDefaults.standardUserDefaults()
        let loggedname = prefs.valueForKey("username")
        let request = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/data.php", postString: "username="+loggedname!.description)
        //if there's a network error
        if(request.responseCode == -1){
            addItem(-1, household: -1, name: "No connection", desc: "")
            dataLoaded = true
            return
        }else if(request.responseCode == 420){ // if the data is recieved
            do {
                let data = request.responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                if let jsonItems = json["items"] as? [[String: AnyObject]] {
                    for item in jsonItems {
                        var temp : Item = Item(id: -1, household: -1, name: "Invalid item", desc: "")
                        //id
                        if let id = item["id"] as? Int {
                            temp.id = id
                        }
                        //household
                        if let household = item["household"] as? Int {
                            temp.household = household
                        }
                        //name
                        if let name = item["name"] as? String {
                            temp.name = name
                        }
                        //description
                        if let description = item["description"] as? String{
                            temp.desc = description
                        }
                        //append the new item
                        items.append(temp)
                    }
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            dataLoaded = true
            return
        }else{ // if there's an error on the server
            addItem(-1, household: -1, name: "Data failed to load", desc: "")
            dataLoaded = true
            return
        }
    }
    
    func addItem(id: Int, household: Int, name: String, desc: String){
        items.append(Item(id: id, household: household, name: name, desc: desc));
    }
    
    func clearData(){
        dataLoaded = false
        items.removeAll()
    }
}
