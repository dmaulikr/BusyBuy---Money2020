//
//  LogInViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textFdTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnBottonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_CapgramLogo: UILabel!
    @IBOutlet weak var txtFd_Username: UITextField!
    @IBOutlet weak var txtFd_Password: UITextField!
    
    @IBOutlet weak var logInActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        txtFd_Password.tintColor = UIColor.whiteColor()
        txtFd_Username.tintColor = UIColor.whiteColor()
        logInActivityIndicator.hidden = true
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
            self.btnBottonConstraint.constant = 300
            self.lbl_CapgramLogo.hidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        UIView.animateWithDuration(0.7) { () -> Void in
            self.textFdTopConstraint.constant = 206
            self.btnBottonConstraint.constant = 45
            self.lbl_CapgramLogo.hidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case txtFd_Username :
            txtFd_Password.becomeFirstResponder()
            return false
        case txtFd_Password :
            txtFd_Password.resignFirstResponder()
            loginUser(txtFd_Username.text, password: txtFd_Password.text)
            return true
        default:
            return false
        }
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        loginUser(txtFd_Username.text, password: txtFd_Password.text)
    }
    
    func loginUser(username: String?, password: String?) {
        switch (username, password) {
        case (.Some(_), .Some(_)) where (username?.characters.count > 0 && password?.characters.count > 0) :
            logInActivityIndicator.hidden = false
            self.txtFd_Password.resignFirstResponder()
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user: PFUser?, error: NSError?) -> Void in
                
               self.logInActivityIndicator.hidden = true
                
                if let auser = user {
                    let userDefaults = NSUserDefaults.defaults()
                    if (!userDefaults.boolForKey(Notification.On.key())) {
                        self.performSegueWithIdentifier(.NotificationAccessViewSegue, sender: self)
                        return
                    }
                    
                    let installation =  PFInstallation.currentInstallation()
                    installation.setObject(auser, forKey: "owner")
                    installation.saveInBackgroundWithBlock({ (succesS:Bool, error: NSError?) -> Void in
                        if succesS {
                            print("saved")
                        }
                    })
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
    
    @IBAction func unwindToRootViewController(sender: UIStoryboardSegue) {
        if let _ = sender.sourceViewController
            as? ViewController {
        }
    }
    
    @IBAction func userTappedScreen(sender: AnyObject) {
        if txtFd_Password.isFirstResponder() {
            txtFd_Password.resignFirstResponder()
        } else if txtFd_Username.isFirstResponder() {
            txtFd_Username.resignFirstResponder()
        }
    }
    
    func updateDeviceDetails() {
        guard let auser = PFUser.currentUser() else {
            return
        }
        
        let installation =  PFInstallation.currentInstallation()
        installation.setObject(auser, forKey: "owner")
        installation.saveInBackgroundWithBlock({ (succesS:Bool, error: NSError?) -> Void in
            if succesS {
                print("saved")
            }
        })
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destVC = segue.destinationViewController as? NotificationViewController where segue.identifier == SegueIdentifier.NotificationAccessViewSegue.rawValue {
            destVC.parentVC = self
        }
    }
}
