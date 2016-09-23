//
//  SIRootViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//


import Foundation

/*!
 This is the root view controller that holds tabs and "Logout" button.
 */
class SIRootViewController : UITabBarController {
    /*!
     It logout from application.
     @param sender -> the event sender
     */
    @IBAction func logout(_ sender: AnyObject) {
        SFAuthenticationManager.shared().logout()
    }
}
