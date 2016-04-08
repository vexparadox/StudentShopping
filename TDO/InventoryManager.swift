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
            addItem("No connection", desc: "", id: -1)
            dataLoaded = true
            return
        }else if(request.responseCode == 420){ // if the data is recieved
            let csv = CSwiftV(String: request.responseString)
            print(csv.headers)
            //add the headers as new items
            for item in csv.headers {
                addItem(item, desc: "", id: 0)
            }
            dataLoaded = true
            return
        }else{ // if there's an error on the server
            addItem("Data failed to load", desc: "", id: -1)
            dataLoaded = true
            return
        }
    }
    
    func addItem(name: String, desc: String, id: Int){
        items.append(Item(id: id, name: name, desc: desc));
    }
    
    func clearData(){
        dataLoaded = false
        items.removeAll()
    }
}
