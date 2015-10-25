//
//  LocationAccessRequestViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import CoreLocation

class LocationAccessViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var giveAccessSwitch: UISwitch!
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
    
    @IBAction func requestLocationAccess(sender: AnyObject) {
        guard giveAccessSwitch.on else {
            return
        }
        
        let manager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        
        manager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            if status == .AuthorizedAlways {
                let userDefaults = NSUserDefaults.defaults()
                
                if giveAccessSwitch.on && !userDefaults.boolForKey(LocationAccess.On.key()){
                    NotificationHelper.askPermission()
                }
                
                userDefaults.setBool(giveAccessSwitch.on, forKey: LocationAccess.On.key())
                userDefaults.synchronize()
            } else if status == .AuthorizedWhenInUse {
                //alert user
                showLocationAccessRequestAlert()
                print("User granted only when in use authorization")
            } else if status == .Denied {
                //alert user
                showLocationAccessRequestAlert()
                print("User denied location access")
            }
    }

}