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
    @IBOutlet var stepAmount : UIStepper!
    @IBOutlet var lblAmount : UILabel!
    @IBOutlet var pickItem : UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddItemClick(sender: UIButton){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://igor.gold.ac.uk/~wmeat002/app/login.php")!)
        request.HTTPMethod = "POST"
        let postString = "username=test&password=test"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            let httpStatus = response as? NSHTTPURLResponse
            if  httpStatus?.statusCode != 420 {           // check for http
                print("Login not successful")
                print("response = \(response)")
            }
            print(httpStatus?.statusCode)
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    //when the stepper is changed
    @IBAction func stepperValueChanged(sender: UIStepper) {
        lblAmount.text = Int(sender.value).description
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }

}

