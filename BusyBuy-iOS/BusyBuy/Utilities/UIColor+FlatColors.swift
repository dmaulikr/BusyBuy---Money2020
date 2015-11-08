//
//  UIColor+Colors.swift
//  Busy Buy
//
//  Created by Prasad Pamidi on 8/12/15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit
import ChameleonFramework

extension UIColor {
    class func mainColor() -> UIColor {
        return UIColor.flatSkyBlueColor()
    }
    
    class func confirmColor() -> UIColor {
        return UIColor(red:0.6, green:0.8, blue:0.37, alpha:1)
    }
    
    class func destructiveColor() -> UIColor {
        return UIColor(red:0.75, green:0.22, blue:0.17, alpha:1)
    }
    
    class func lightGray() -> UIColor {
        return UIColor(red:0.91, green:0.91, blue:0.92, alpha:1)
    }
    
    class func fontColor() -> UIColor {
        return UIColor.whiteColor()
    }
}
