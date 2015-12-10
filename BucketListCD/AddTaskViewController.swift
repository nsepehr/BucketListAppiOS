//
//  AddTaskViewController.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/9/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    

    // Bar Buttons
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var textField: UITextField!

    @IBAction func editingChanged(sender: AnyObject) {
        // If the text field value changes to non empty... enable save button
        if self.textField.text == "" {
            // Enable save button
            self.saveButton.enabled = false
        } else {
            self.saveButton.enabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Return the keyboard
        self.textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("Touches began in add task")
        self.view.endEditing(true)
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
