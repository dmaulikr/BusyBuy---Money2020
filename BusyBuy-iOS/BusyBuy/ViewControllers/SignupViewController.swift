//
//  SignupViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textFdTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnBottonConstraint: NSLayoutConstraint!

    @IBOutlet weak var lbl_userEmail: UITextField!
    @IBOutlet weak var lbl_BusyBuy_Logo: UILabel!
    @IBOutlet weak var lbl_userPwd: UITextField!
    @IBOutlet weak var lbl_userConfrmPwd: UITextField!
    
    @IBOutlet weak var logInActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        logInActivityIndicator.hidden = true

        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShowNotification:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHideNotification:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        
        UIView.animateWithDuration(0.7) { () -> Void in
            self.textFdTopConstraint.constant = 100
            self.btnBottonConstraint.constant = 220
            self.lbl_BusyBuy_Logo.hidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        UIView.animateWithDuration(0.7) { () -> Void in
            self.textFdTopConstraint.constant = 206
            self.btnBottonConstraint.constant = 45
            self.lbl_BusyBuy_Logo.hidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case lbl_userPwd :
            lbl_userPwd.becomeFirstResponder()
            return false
        case lbl_userPwd :
            lbl_userConfrmPwd.becomeFirstResponder()
            return true
        case lbl_userConfrmPwd:
            lbl_userConfrmPwd.resignFirstResponder()
            if lbl_userPwd.text == lbl_userConfrmPwd.text {
                signUpUser(lbl_userEmail.text, password: lbl_userConfrmPwd.text)
            }
            return false
        default:
            return false
        }
    }
    
    @IBAction func signUpUser(sender: AnyObject) {
        if lbl_userPwd.text == lbl_userConfrmPwd.text {
            signUpUser(lbl_userEmail.text, password: lbl_userConfrmPwd.text)
        }
    }
    
    func signUpUser(username: String?, password: String?) {
        switch (username, password) {
        case (.Some(_), .Some(_)) where (username?.characters.count > 0 && password?.characters.count > 0) :
            logInActivityIndicator.hidden = false
            self.lbl_userConfrmPwd.resignFirstResponder()
            
            let user = PFUser()
            user.username = lbl_userEmail.text
            user.password = lbl_userPwd.text
            user.email = lbl_userEmail.text
            
            user.signUpInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                let userDefaults = NSUserDefaults.defaults()
                if (!userDefaults.boolForKey(Notification.On.key())) {
                    self.performSegueWithIdentifier(.NotificationAccessViewSegue, sender: self)
                    return
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        case (.Some(_), .None):
            print("Password is missing", terminator: "")
        case (.None, .Some(_)):
            print("Username is missing", terminator: "")
        case (.None, .None):
            print("Both username and password are missing", terminator: "")
        default:
            print("Invalid values")
        }
    }
    
    @IBAction func userTappedScreen(sender: AnyObject) {
        if lbl_userPwd.isFirstResponder() {
            lbl_userPwd.resignFirstResponder()
        } else if lbl_userEmail.isFirstResponder() {
            lbl_userEmail.resignFirstResponder()
        } else if lbl_userConfrmPwd.isFirstResponder() {
            lbl_userConfrmPwd.resignFirstResponder()
        }
    }

}
