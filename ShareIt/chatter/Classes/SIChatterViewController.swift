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
    func request(_ request: SFRestRequest!, didLoadResponse dataResponse: Any!) {
        if request.path.hasSuffix("/feed-items") {
            // Feed item post response
            print("SIChatterViewController.request:didLoadResponse: shared item has been successfully posted.")
            SIChatterModel.showAlert(alertTitle: "Success", alertMessage: "The shared item has been successfully posted.",
                controller : self)
        }
    }

    /*!
     This delegate is called when a request has failed due to an error.
     @param request -> the request
     @param error -> the error
     */
    func request(_ request: SFRestRequest!, didFailLoadWithError error: Error!) {
        print("SIChatterViewController.request:didFailLoadWithError: REST API request failed: ", error!)
        SIChatterModel.showErrorAlert(alertMessage: "Request to Salesforce failed.", controller : self)
    }

    /*!
     This delegate is called when a request has be cancelled.
     @param request -> the request
     */
    func requestDidCancelLoad(_ request: SFRestRequest!) {
        print("SIChatterViewController.requestDidCancelLoad: REST API request cancelled: ", request!)
        SIChatterModel.showErrorAlert(alertMessage: "Request to Salesforce is cancelled.", controller : self)
    }
    
    /*!
     This delegate is called when a request has timed out.
     @param -> request the request
     */
    func requestDidTimeout(_ request: SFRestRequest!) {
        print("ChatterShareViewController.requestDidTimeout: REST API request timeout: ", request!)
        SIChatterModel.showErrorAlert(alertMessage: "Request to Salesforce timeout.", controller : self)
    }
}
