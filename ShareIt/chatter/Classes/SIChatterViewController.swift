//
//  SIChatterViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

/*!
 This is the base class for Chatter share view controllers.
 */

class SIChatterViewController : UIViewController, SFRestDelegate {
    /*!
     This delegate is called when a request has finished loading.
     @param request -> the request
     @param jsonResponse -> the response
     */
    func request(request : SFRestRequest, didLoadResponse jsonResponse : AnyObject) {
        if request.path.hasSuffix("/feed-items") {
            // Feed item post response
            NSLog("SIChatterViewController.request:didLoadResponse: shared item has been successfully posted.");
            SIChatterModel.showAlert(alertTitle: "Success", alertMessage: "The shared item has been successfully posted.",
                controller : self)
        }
    }

    /*!
     This delegate is called when a request has failed due to an error.
     @param request -> the request
     @param error -> the error
     */
    func request(request : SFRestRequest, didFailLoadWithError error : NSError) {
        NSLog("SIChatterViewController.request:didFailLoadWithError: REST API request failed: %@", error);
        SIChatterModel.showErrorAlert(alertMessage: "Request to Salesforce failed.", controller : self)
    }

    /*!
     This delegate is called when a request has be cancelled.
     @param request -> the request
     */
    func requestDidCancelLoad(request : SFRestRequest) {
        NSLog("SIChatterViewController.requestDidCancelLoad: REST API request cancelled: %@", request);
        SIChatterModel.showErrorAlert(alertMessage: "Request to Salesforce is cancelled.", controller : self)
    }

    /*!
     This delegate is called when a request has timed out.
     @param -> request the request
     */
    func requestDidTimeout(request : SFRestRequest) {
        NSLog("ChatterShareViewController.requestDidTimeout: REST API request timeout: %@", request);
        SIChatterModel.showErrorAlert(alertMessage: "Request to Salesforce timeout.", controller : self)
    }
}
