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
        if(txtItem.text! == ""){
            activityMonitor.stopAnimating()
            return
        }
        let request = PostRequest(url: "http://igor.gold.ac.uk/~wmeat002/app/add.php", postString: "item="+txtItem.text!+"&desc="+txtDesc.text!)
        if(request.responseCode == 420){
            activityMonitor.stopAnimating()
            //initiate data reload
            invManager.getData()
            tabBarController?.selectedIndex = 0
        }else{
            activityMonitor.stopAnimating()
        }
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

