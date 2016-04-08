//
//  FirstViewController.swift
//  TDO
//
//  Created by William Meaton on 02/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblItems : UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FirstViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //for refreshing the table
        self.tblItems.addSubview(self.refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        //check if they're logged in
        let prefs = NSUserDefaults.standardUserDefaults()
        let loggedin = prefs.boolForKey("logged")
        if(loggedin){
            //if so call the data and wait for it to load
            invManager.getData()
            while(!invManager.dataLoaded){}
        }else{
            //else just add a login prompt
            invManager.addItem("Please login", desc: "", id: -1)
        }
        //then reload the table
        tblItems.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        //if the data hasn't been loaded, or has been set to reload
        if(!invManager.dataLoaded){
            loadData()
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        //always reload the data here, no matter what its current state
        loadData()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            //get the item name
            let itemName = invManager.items[indexPath.row].name
            //send a request to delete it
            let request = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/remove.php")!)
            request.HTTPMethod = "POST"
            let postString = "name="+itemName
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            //create a task thread
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else {
                    //talk of a network error
                    //has to be on a different thread because it edits the ui
                    dispatch_async(dispatch_get_main_queue()) {
                        self.loadData()
                    }
                    return
                }
                //get the HTTPStatus
                let httpStatus = response as? NSHTTPURLResponse
                print(httpStatus?.statusCode)
                if  httpStatus?.statusCode == 420 { // check for http
                    dispatch_async(dispatch_get_main_queue()) {
                        self.loadData()
                    }
                }
            }
            task.resume()
        }
    }

    
    //UI table view data
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return invManager.items.count
    }
    //load the cells with the items in the inv manager
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Test")
        cell.textLabel!.font = UIFont(name: "Avenir", size: 18)
        cell.detailTextLabel!.font = UIFont(name: "Avenir", size: 12)
        cell.textLabel!.text = invManager.items[indexPath.row].name
        cell.detailTextLabel!.text = String(invManager.items[indexPath.row].desc)
        return cell
    }
}