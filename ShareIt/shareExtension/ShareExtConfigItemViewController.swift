//
//  ShareExtConfigItemViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation
import Social

/*!
 This is the view controller for editing share configuration item.
 */
class ShareExtConfigItemViewController : UIViewController {
    
    var configurationItem : SLComposeSheetConfigurationItem?
    
    var shareExtViewController : ShareExtViewController?
    
    @IBOutlet var valueView: UITextField?
    
    /*!
     This function is called when the value of the item changed.
     @param sender -> the event sender
     */
    @IBAction func valueDidChange(_ sender: AnyObject) {
        if (configurationItem != nil) {
            configurationItem!.value = valueView!.text
            shareExtViewController!.validateContent()
        }
    }
    
    override func viewDidLoad()  {
        if (configurationItem != nil) {
            valueView!.text = configurationItem!.value
        }
    }
}
