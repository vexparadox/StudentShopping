//
//  LoginViewController.swift
//  TDO
//
//  Created by William Meaton on 04/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{

    @IBOutlet var lblTitle : UILabel!
    
    //to login
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var lblResponse : UILabel!
    @IBOutlet var activityMonitor : UIActivityIndicatorView!
    @IBOutlet var btnLogin : UIButton!
    //to logout
    @IBOutlet var btnLogout : UIButton!
    
    var loggedin : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        //reset the response label
        lblResponse.text = ""
        let prefs = NSUserDefaults.standardUserDefaults()
        loggedin = prefs.boolForKey("logged")
        let loggedname = prefs.valueForKey("username")
        //switch between logged in or out
        if(loggedin){
            btnLogin.hidden = true
            txtUsername.hidden = true
            txtPassword.hidden = true
            lblTitle.text = "Hello, "+loggedname!.description
            btnLogout.hidden = false
        }else{
            btnLogin.hidden = false
            txtUsername.hidden = false
            txtPassword.hidden = false
            lblTitle.text = "Login"
            btnLogout.hidden = true
        }
        
    }
    
    @IBAction func btnLogoutClick(sender: UIButton){
        //wipe the logout
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(false, forKey: "logged")
        prefs.removeObjectForKey("username")
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func btnLoginClick(sender: UIButton){
        activityMonitor.startAnimating()
        //create a request
        let request = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/login.php")!)
        request.HTTPMethod = "POST"
        //pass the username and password
        let postString = "username="+txtUsername.text!+"&password="+txtPassword.text!
        //new request
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        //create a task thread
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check forfundamental networking error
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Network error"
                    self.activityMonitor.stopAnimating()
                }
                return
            }
            //get the HTTPStatus
            let httpStatus = response as? NSHTTPURLResponse
            print(httpStatus?.statusCode)
            //if it's wrong
            if  httpStatus?.statusCode != 420 { // check for http
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Login failed"
                    self.activityMonitor.stopAnimating()
                }
            }else{
                //if it's right
                dispatch_async(dispatch_get_main_queue()) {
                    let prefs = NSUserDefaults.standardUserDefaults()
                    prefs.setBool(true, forKey: "logged")
                    prefs.setValue(self.txtUsername.text!, forKey: "username")
                    self.lblResponse.text = "Login successful"
                    self.txtUsername.text = ""
                    self.txtPassword.text = ""
                    self.activityMonitor.stopAnimating()
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }
        //resume the task
        task.resume()
    }
}