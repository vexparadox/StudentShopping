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
    @IBOutlet var activityMonitor : UIActivityIndicatorView!
    @IBOutlet var btnLogin : UIButton!
    @IBOutlet var btnSignup : UIButton!
    //to logout
    @IBOutlet var btnLogout : UIButton!
    
    var loggedin : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPassword.delegate = self
        txtUsername.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if textField == txtUsername{
            txtPassword.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
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
            lblTitle.text = "Hello, "+loggedname!.description
            btnLogout.hidden = false
        }else{
            btnLogin.hidden = false
            txtUsername.hidden = false
            txtPassword.hidden = false
            btnSignup.hidden = false
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
        prefs.removeObjectForKey("userToken")
        prefs.removeObjectForKey("userID")
        prefs.removeObjectForKey("userHousehold")
        invManager.clearData()
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func btnLoginClick(sender: UIButton){
        var password : String = ""
        var username : String = ""
        var responseSalt : String = ""
        activityMonitor.startAnimating()
        username = txtUsername.text!
        //get the salt
        let saltRequest = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/salt.php", postString: "username="+username)
        //get the response salt
        saltRequest.start { (resultString, resultCode) in
            responseSalt = resultString
            //if there's no salt found
            if(responseSalt == ""){
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "User not found"
                    self.activityMonitor.stopAnimating()
                    return
                }
            }
            password = saltHash(self.txtPassword.text!, salt: responseSalt)
            //compare with the server
            self.checkLogin(password, username: username)
        }
    }
    
    //compares the login and changed the approiate things if correct
    func checkLogin(password: String, username: String){
        let loginRequest = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/login.php", postString: "username="+username+"&password="+password)
        //start the login request
        loginRequest.start { (resultString, resultCode) in
            switch resultCode{
            case 420:
                //parse the data
                do{
                    let data = resultString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    let prefs = NSUserDefaults.standardUserDefaults()
                    prefs.setBool(true, forKey: "logged")
                    //id
                    if let id = json["id"] as? Int {
                        prefs.setInteger(id, forKey: "userHousehold")
                    }
                    //household
                    if let household = json["household"] as? String {
                        prefs.setValue(household, forKey: "userHousehold")
                    }
                    //name
                    if let name = json["name"] as? String {
                        prefs.setValue(name, forKey: "username")
                    }
                    //token
                    if let token = json["token"] as? String {
                        prefs.setValue(token, forKey: "userToken")
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Login successful"
                    self.txtUsername.text = ""
                    self.txtPassword.text = ""
                    self.activityMonitor.stopAnimating()
                    self.tabBarController?.selectedIndex = 0
                }
                break
            case -1:
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Network error"
                    self.activityMonitor.stopAnimating()
                }
                break
            default:
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblResponse.text = "Login failed"
                    self.activityMonitor.stopAnimating()
                }
                break
            }
        }
    }
}