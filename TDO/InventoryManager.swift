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
    
    func getData(completion: ()-> Void){
        self.clearData()
        var loggedToken : String?
        let prefs = NSUserDefaults.standardUserDefaults()
        loggedToken = prefs.valueForKey("userToken")?.description
        //send a token
        let request = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/data.php", postString: "token="+loggedToken!)
        //start the request
        request.start { (resultString, resultCode) in
            switch resultCode{
            case 420:
                //parse the data
                do {
                    let data = request.responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    //parse that data
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
                            self.items.append(temp)
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
                self.dataLoaded = true
                break
            case -1:
                self.addItem(-1, household: -1, name: "No connection", desc: "")
                self.dataLoaded = true
                break
            case 422:
                //if the token is outdated
                self.addItem(-1, household: -1, name: "Login expired", desc: "")
                self.dataLoaded = true
                break
            case 421:
                //if there's no data
                self.addItem(-1, household: -1, name: "No items yet", desc: "Try adding some more")
                self.dataLoaded = true
                break
            default:
                //some other error
                self.addItem(-1, household: -1, name: "Data failed to load", desc: String(request.responseCode))
                self.dataLoaded = true
                break
            }
            completion()
        }
    }
    
    func addItem(id: Int, household: Int, name: String, desc: String){
        items.append(Item(id: id, household: household, name: name, desc: desc))
    }
    
    func clearData(){
        dataLoaded = false
        items.removeAll()
    }
}
