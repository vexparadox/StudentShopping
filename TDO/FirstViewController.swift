//
//  FirstViewController.swift
//  TDO
//
//  Created by William Meaton on 02/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblItems : UITableView!
    @IBOutlet weak var btnAddItem: UIBarButtonItem!
    
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
    
    override func viewWillAppear(animated: Bool) {
        if !invManager.dataLoaded && !invManager.dataBeingLoaded {
            // if the data isn't loaded and not being loaded, reload it from the server
            loadData()
        }else{
            tblItems.reloadData() // if not, just make sure the table is updated
        }
        
        //don't allow additions if not logged in
        let prefs = NSUserDefaults.standardUserDefaults()
        if !prefs.boolForKey("logged"){
            btnAddItem.enabled = false
        }else{
            btnAddItem.enabled = true
        }
    }
        
    //MARK: Data
    func loadData(){
        refreshControl.beginRefreshing()
        //check if they're logged in
        let prefs = NSUserDefaults.standardUserDefaults()
        let loggedin = prefs.boolForKey("logged")
        if(loggedin){
            //if so call the get data
            invManager.getData({
                dispatch_async(dispatch_get_main_queue()) {
                    self.tblItems.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        }else{
            //else just add a login prompt
            invManager.clearData()
            invManager.addItem(-1, household: -1, name: "Please login", desc: "Or sign up for free")
            //then reload the table
            tblItems.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    //MARK: Table
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            //get the item name
            let itemID = String(invManager.items[indexPath.row].id)
            if itemID != "-1"{
                _ = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/remove.php", postString: "id="+itemID).start({ (resultString, resultCode) in
                    self.loadData()
                })
            }
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FirstViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()

    func handleRefresh(refreshControl: UIRefreshControl) {
        //dont reload if it is
        if invManager.dataBeingLoaded {
            refreshControl.endRefreshing()
            return
        }
        //always reload the data here, no matter what its current state
        loadData()
    }
    
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