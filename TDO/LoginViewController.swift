//
//  LoginViewController.swift
//  TDO
//
//  Created by William Meaton on 04/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var lblTitle : UILabel!
    
    //to login
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var lblResponse : UILabel!
    @IBOutlet var lblSignup : UILabel!
    @IBOutlet var activityMonitor : UIActivityIndicatorView!
    @IBOutlet var btnLogin : UIButton!
    @IBOutlet var btnSignup : UIButton!
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
            btnSignup.hidden = true
            lblSignup.hidden = true
            lblTitle.text = "Hello, "+loggedname!.description
            btnLogout.hidden = false
        }else{
            btnLogin.hidden = false
            txtUsername.hidden = false
            txtPassword.hidden = false
            btnSignup.hidden = false
            lblSignup.hidden = false
            lblTitle.text = "Login"
            btnLogout.hidden = true
        }
    }
    
    @IBAction func btnSignUpClick(sender: UIButton){
        //open the signup view
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signupViewController = storyBoard.instantiateViewControllerWithIdentifier("SignUpView") as! SignUpViewController
        self.presentViewController(signupViewController, animated:true, completion:nil)

    }

    
    @IBAction func btnLogoutClick(sender: UIButton){
        //wipe the logout
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(false, forKey: "logged")
        prefs.removeObjectForKey("username")
        invManager.clearData()
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func btnLoginClick(sender: UIButton){
        var password : String = ""
        var responseSalt : String = ""
        var saltRecieved : Bool = false
        activityMonitor.startAnimating()
        
        let saltRequest = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/salt.php")!)
        saltRequest.HTTPMethod = "POST"
        let postSaltString = "username="+txtUsername.text!
        saltRequest.HTTPBody = postSaltString.dataUsingEncoding(NSUTF8StringEncoding)
        //create a task thread
        let saltTask = NSURLSession.sharedSession().dataTaskWithRequest(saltRequest) { data, response, error in
            guard error == nil && data != nil else {
                //talk of a network error
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Network error"
                    saltRecieved = true
                    self.activityMonitor.stopAnimating()
                }
                return
            }
            //get the HTTPStatus
            let httpStatus = response as? NSHTTPURLResponse
            print(httpStatus?.statusCode)
            if  httpStatus?.statusCode == 420 { // check for http
                //save the salt
                responseSalt = String(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
                saltRecieved = true
            }else{
                saltRecieved = true
            }
        };saltTask.resume()
        while(!saltRecieved){}//wait for the salt
        //if there's no salt found
        if(responseSalt == ""){
            lblResponse.text = "User not found"
            activityMonitor.stopAnimating()
            return
        }
        print("salt :"+responseSalt)
        password = txtPassword.text!+responseSalt //append the salt
        password = sha256(password.dataUsingEncoding(NSUTF8StringEncoding)!) //hash it
        //remove the <>
        password = password.stringByReplacingOccurrencesOfString("<", withString: "")
        password = password.stringByReplacingOccurrencesOfString(">", withString: "")
        print("password: "+password)
        //compare with the server
        //create a request
        let request = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/login.php")!)
        request.HTTPMethod = "POST"
        //pass the username and password
        let postString = "username="+txtUsername.text!+"&password="+password
        //new request
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        //create a task thread
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                //talk of a network error
                //has to be on a different thread because it edits the ui
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
                //has to be on a different thread because it edits the ui
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Login failed"
                    self.activityMonitor.stopAnimating()
                }
            }else{
                //if it's right
                //has to be on a different thread because it edits the ui
                dispatch_async(dispatch_get_main_queue()) {
                    //set preferences to logged in
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