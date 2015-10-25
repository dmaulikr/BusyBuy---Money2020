//
//  UITabBar+CapGram.swift
//  CapGram
//
//  Created by Prasad Pamidi on 8/13/15.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

import UIKit

/** CapGram Extends UITabBar

*/
extension UITabBar {
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 50);
    }
}
