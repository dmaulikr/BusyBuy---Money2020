//
//  ViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if let auser = PFUser.currentUser() {
            let installation =  PFInstallation.currentInstallation()
            installation.setObject(auser, forKey: "owner")
            installation.saveInBackgroundWithBlock({ (succesS:Bool, error: NSError?) -> Void in
                if succesS {
                    print("saved")
                }
            })

            self.performSegueWithIdentifier(.HomeViewSegue, sender: self)
        } else {
            self.performSegueWithIdentifier(.LogInViewSegue, sender: self)
        }
        
    }
}