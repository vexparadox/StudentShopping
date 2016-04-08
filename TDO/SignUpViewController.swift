//
//  SignUpViewController.swift
//  TDO
//
//  Created by William Meaton on 08/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import UIKit
class SignUpViewController: UIViewController{
    
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var txtPassword2 : UITextField!
    @IBOutlet var txtNewHousehold : UITextField!
    @IBOutlet var txtHouseholdPassword : UITextField!
    @IBOutlet var swtchNewHousehold : UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        swtchNewHousehold.on = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func cancelClicked(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
