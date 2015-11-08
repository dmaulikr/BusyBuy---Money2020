//
//  NotificationRequestViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit


class NotificationViewController: UIViewController {
    @IBOutlet weak var notifyMeSwitch: UISwitch!
    
    weak var parentVC: LoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBAction func showHomeScreen(sender: AnyObject) {
        let userDefaults = NSUserDefaults.defaults()
        
        if notifyMeSwitch.on && !userDefaults.boolForKey(Notification.On.key()){
            NotificationHelper.askPermission()
        }
        
        userDefaults.setBool(notifyMeSwitch.on, forKey: Notification.On.key())
        userDefaults.synchronize()
        
        self.parentVC?.updateDeviceDetails()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}