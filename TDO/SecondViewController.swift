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
    @IBOutlet var lblResponse : UILabel!
    @IBOutlet var activityMonitor : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtItem.delegate = self
        txtDesc.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        lblResponse.text = ""
    }
    
    //to add an item
    @IBAction func btnAddItemClick(sender: UIButton){
        let prefs = NSUserDefaults.standardUserDefaults()
        //check they're actually logged in
        if !prefs.boolForKey("logged"){
            lblResponse.text = "Please login"
            return
        }
        activityMonitor.startAnimating()
        //you require a name
        if(txtItem.text! == ""){
            lblResponse.text = "Name needed"
            activityMonitor.stopAnimating()
            return
        }
        var loggedToken : String?
        loggedToken = prefs.valueForKey("userToken")?.description
        let request = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/add.php", postString: "item="+txtItem.text!+"&desc="+txtDesc.text!+"&token="+loggedToken!)
        if(request.responseCode == 420){
            //initiate data reload
            invManager.getData()
            activityMonitor.stopAnimating()
            tabBarController?.selectedIndex = 0
        }else if(request.responseCode == 422){
            lblResponse.text = "Login expired"
            activityMonitor.stopAnimating()
        }else{
            lblResponse.text = "Server error"
            activityMonitor.stopAnimating()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if textField == txtItem {
            txtDesc.isFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }
}

