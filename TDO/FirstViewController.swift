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
    @IBOutlet var activityMonitor : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        tblItems.reloadData()
        let prefs = NSUserDefaults.standardUserDefaults()
        let loggedin = prefs.boolForKey("logged")
        if(loggedin){
            activityMonitor.startAnimating()
            invManager.getData()
            while(!invManager.dataLoaded){}
            activityMonitor.stopAnimating()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            invManager.items.removeAtIndex(indexPath.row)
        }
        tblItems.reloadData()
    }

    
    //UI table view data
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return invManager.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Test")
        cell.textLabel!.font = UIFont(name: "Avenir", size: 22)
        cell.detailTextLabel!.font = UIFont(name: "Avenir", size: 22)
        cell.textLabel!.text = invManager.items[indexPath.row].name
        cell.detailTextLabel!.text = String(invManager.items[indexPath.row].desc)
        return cell
    }
}