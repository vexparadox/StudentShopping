//
//  SecondViewController.swift
//  TDO
//
//  Created by William Meaton on 02/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtItem : UITextField!
    @IBOutlet weak var txtDesc : UITextField!
    @IBOutlet weak var lblResponse : UILabel!
    @IBOutlet weak var activityMonitor : UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtItem.delegate = self
        txtDesc.delegate = self
        checkFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation
    
    override func viewWillAppear(animated: Bool) {
        //empty the response
        lblResponse.text = ""
        //make the text box appear
        txtItem.becomeFirstResponder()
    }
    
    //MARK: Actions
    @IBAction func closeWindow(sender: AnyObject) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addItem(sender: AnyObject){
        activityMonitor.startAnimating()
        var loggedToken : String?
        let prefs = NSUserDefaults.standardUserDefaults()
        loggedToken = prefs.valueForKey("userToken")?.description
        let request = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/add.php", postString: "item="+txtItem.text!+"&desc="+txtDesc.text!+"&token="+loggedToken!)
        if(request.responseCode == 420){
            //initiate data reload
            invManager.getData()
            activityMonitor.stopAnimating()
            //dismiss this view
            dismissViewControllerAnimated(true, completion: nil)
        }else if(request.responseCode == 422){
            lblResponse.text = "Login expired"
            activityMonitor.stopAnimating()
        }else{
            lblResponse.text = "Server error"
            activityMonitor.stopAnimating()
        }
    }
    
    //MARK: Text Field
    func textFieldDidEndEditing(textField: UITextField) {
        checkFields()
    }
    
    func checkFields(){
        saveButton.enabled = true
        //if no checks come through, it will remain enabled
        if txtItem.text! == "" {
            lblResponse.text = "Item name needed"
            saveButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if textField === txtItem {
            txtDesc.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }
}

