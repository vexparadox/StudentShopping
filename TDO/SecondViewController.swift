//
//  SecondViewController.swift
//  TDO
//
//  Created by William Meaton on 02/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtItem : UITextField!
    @IBOutlet var txtDesc : UITextField!
    @IBOutlet var activityMonitor : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //to add an item
    @IBAction func btnAddItemClick(sender: UIButton){
        activityMonitor.startAnimating()
        //you require a name
        if(txtItem.text == ""){
            activityMonitor.stopAnimating()
            return
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/add.php")!)
        request.HTTPMethod = "POST"
        let postString = "item="+txtItem.text!+"&desc="+txtDesc.text!
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            let httpStatus = response as? NSHTTPURLResponse
            if  httpStatus?.statusCode == 420 {           // check for http
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityMonitor.stopAnimating()
                    //initiate data reload
                    invManager.dataLoaded = false
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }
        task.resume()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if(textField.isEqual(txtItem)){
            txtDesc.isFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }

}

