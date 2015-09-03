//
//  SILinkViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation

/*!
 This is the view controller used to share link.
 */

class SILinkViewController : SIChatterViewController {
    
    @IBOutlet var link: UITextField!

    @IBOutlet var linkName: UITextField!

    @IBOutlet var message: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // It hides keyboard on tapping on screen
    func hideKeyboard(){
        view.endEditing(true)
    }

    
    /*!
     It shares the link to chatter wall
     @param sender -> the event sender
     */
    @IBAction func shareLink(sender: AnyObject) {
        var msg = ""
        if link.text.isEmpty {
            msg = msg + "Link is required!\n"
        }
        if !(NSURL(string:link.text) != nil) {
            msg = msg + "Link is not valid URL!\n"
        }
        if linkName.text.isEmpty {
            msg = msg + "Link Name is required!\n"
        }
        if msg.isEmpty {
            // Post feed item with link
            SIChatterModel.postFeedItemToChatterWall(message.text, withLink: link.text,
                linkName: linkName.text, delegate: self)
        } else {
            SIChatterModel.showErrorAlert(msg, controller : self)
        }
    }
}