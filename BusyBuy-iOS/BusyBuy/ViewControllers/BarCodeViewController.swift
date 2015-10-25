//
//  BarCodeViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import Parse

class BarCodeViewController: UIViewController {
    
    @IBOutlet weak var imgVw_barCode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let installation = PFInstallation.currentInstallation()
        
        let deviceToken = installation.deviceToken
        let userId = PFUser.currentUser()?.objectId
        
        print(userId!)
        print(deviceToken!)
        
        let json_String = "{\"device_token\": \(deviceToken!), \"customer_id\" : \(userId!)}"
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter!.setValue(json_String.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false), forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        imgVw_barCode.image = UIImage(CIImage: filter!.outputImage!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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

}
