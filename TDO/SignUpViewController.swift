//
//  SignUpViewController.swift
//  TDO
//
//  Created by William Meaton on 08/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit
class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var txtUsername : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var txtPassword2 : UITextField!
    @IBOutlet weak var txtNewHousehold : UITextField!
    @IBOutlet weak var txtHouseholdPassword : UITextField!
    @IBOutlet weak var swtchNewHousehold : UISwitch!
    @IBOutlet weak var pickerHouseholds : UIPickerView!
    @IBOutlet weak var lblResponse : UILabel!
    
    struct household {
        var id : Int
        var name : String?
    }
    var households = [household]()
    var pickerDataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUsername.delegate = self
        txtPassword.delegate = self
        txtPassword2.delegate = self
        txtNewHousehold.delegate = self
        txtHouseholdPassword.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpClicked(sender: UIButton){
        var userPassword : String?
        var userSalt : String?
        //if the username is empty
        if txtUsername.text! == "" {
            lblResponse.text = "Username required"
            return
        }
        //if the password is too short
        if txtPassword.text!.characters.count < 6 {
            lblResponse.text = "Password too short"
            return
        }
        //if the passwords don't match
        if txtPassword.text! != txtPassword2.text!{
            lblResponse.text = "Passwords don't match"
            return
        }
        userSalt = randomAlphaNumericString(11)
        userPassword = saltHash(userPassword!, salt: userSalt!)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        lblResponse.text = ""
        //get the households the user can join
        let request = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/households.php", postString: "")
        households.removeAll()
        pickerDataSource.removeAll()
        do{
            let data = request.responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let jsonItems = json["households"] as? [[String: AnyObject]] {
                for item in jsonItems {
                    var temp : household = household(id: -1, name: "")
                    //get id
                    if let id = item["id"] as? Int{
                        temp.id = id
                    }
                    
                    //get name
                    if let name = item["name"] as? String{
                        pickerDataSource.append(name)
                        temp.name = name
                    }
                    households.append(temp)
                }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
        pickerHouseholds.reloadAllComponents()
    }

    @IBAction func cancelClicked(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if textField == self.txtUsername {
            self.txtPassword.becomeFirstResponder()
        }else if textField == self.txtPassword{
            self.txtPassword2.becomeFirstResponder()
        }else if textField == self.txtPassword2{
            self.txtNewHousehold.becomeFirstResponder()
        } else{
            self.txtHouseholdPassword.becomeFirstResponder()
        }
        return true
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
}
