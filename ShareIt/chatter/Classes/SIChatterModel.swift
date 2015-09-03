//
//  SIChatterModel.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation

/*!
 It represents key for saving Salesofrce user account in NSUserDefaults.
 */
let SINSUserDefaultsSFUserAccountKey = "SFUserAccount"

/*!
 It represents the Salesforce REST API version.
 */
let SISFRestAPIVersion = "v29.0"

/*!
 It represents the Salesforce REST API url for post feed items to chatter wall.
 */
let SIPostFeedItemsToChatterWallURL = "\(SISFRestAPIVersion)/chatter/feeds/news/me/feed-items"


/*!
 This class provides utility methods for this application.
 */

final class SIChatterModel {
   
    /*!
     Post a feed item to Salesforce Chatter with a link.
     @param feedMsg -> the feed item msg
     @param link the -> link
     @param linkName -> the link name
     @param delegate -> the SFRestDelegate to use
     */
    class func postFeedItemToChatterWall(feedMsg : String, withLink link : String, linkName : String, delegate : SFRestDelegate) {
        let payloadData = [
            "attachment" : [ "attachmentType" : "Link", "url" : link, "urlName" : linkName],
            "body" : ["messageSegments" : [["type" : "Text", "text" : feedMsg]]]
        ]
        let request = SFRestRequest.requestWithMethod(SFRestMethodPOST, path: SIPostFeedItemsToChatterWallURL,
            queryParams: payloadData) as! SFRestRequest
        SFRestAPI.sharedInstance().send(request, delegate: delegate)
    }
    
    /*!
     Upload a file to Salesforce.
     @param fileName -> the file name
     @param fileContent -> the file content
     @param mimeType -> the MIME type
     @param delegate -> the SFRestDelegate to use
     */
    class func uploadFile(fileName : String, fileContent : NSData, mimeType : String, delegate : SFRestDelegate) {
        let request = SFRestAPI.sharedInstance().requestForUploadFile(
            fileContent, name: fileName, description: nil, mimeType: mimeType)
        SFRestAPI.sharedInstance().send(request, delegate: delegate)
    }

    /*!
     Post a feed item to Salesforce Chatter with an existing document.
     @param feedMsg -> the feed item msg
     @param contentDocumentId -> the ID of the document
     @param delegate -> the SFRestDelegate to use
    */
    class func postFeedItemToChatterWall(feedMsg : String, withExistingDocument contentDocumentId : String, delegate : SFRestDelegate) {
        let payloadData = [
            "attachment" : [ "attachmentType" : "ExistingContent", "contentDocumentId" : contentDocumentId],
            "body" : ["messageSegments" : [["type" : "Text", "text" : feedMsg]]]
        ]
        let request = SFRestRequest.requestWithMethod(SFRestMethodPOST, path: SIPostFeedItemsToChatterWallURL,
            queryParams: payloadData) as! SFRestRequest
        SFRestAPI.sharedInstance().send(request, delegate: delegate)
    }
    
    /*!
     Get the name of the app suite or app group.
     @return the name of the app suite
     */
    class func getAppSuiteName() -> String {
        let dict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource(nil, ofType: "plist")!)
        return dict!.objectForKey("AppSuiteName") as! String
    }

    /*!
     It saves salesforce user account.
     @param sfUserAccount -> the salesforce user account to save, nil will result the user account to be removed
     @return true if saved successfully, false otherwise
     */
    class func saveSFUserAccount(sfUserAccount : SFUserAccount?) -> Bool {
        let sharedUserDefaults = NSUserDefaults(suiteName: getAppSuiteName())
        if (sfUserAccount != nil) {
            sharedUserDefaults!.setObject(NSKeyedArchiver.archivedDataWithRootObject(sfUserAccount!),
                forKey: SINSUserDefaultsSFUserAccountKey)
        } else {
            sharedUserDefaults!.removeObjectForKey(SINSUserDefaultsSFUserAccountKey)
        }
        return sharedUserDefaults!.synchronize()
    }
    
    /*!
     Get salesforce user account.
     @return the salesforce user account. nil if no salesforce user account is present.
     */
    class func getSFUserAccount() -> SFUserAccount? {
        let sharedUserDefaults = NSUserDefaults(suiteName: getAppSuiteName())
        if let data = sharedUserDefaults!.objectForKey(SINSUserDefaultsSFUserAccountKey) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? SFUserAccount
        } else {
            return nil
        }
    }

    /*!
     It shows error alert.
     @param alertMessage -> the alert message
     @param controller -> the UIViewController
     */
    class func showErrorAlert(alertMessage : String, controller : UIViewController) {
        showAlert("Error", alertMessage: alertMessage, controller : controller)
    }

    /*!
     It shows alert without action handler.
     @param alertTitle -> the alert title
     @param alertMessage -> the alert message
     @param controller -> the UIViewController
     */
    class func showAlert(alertTitle : String, alertMessage : String, controller : UIViewController) {
        showAlert(alertTitle, alertMessage: alertMessage, handler : nil, controller: controller)
    }

    /*!
     It shows alert.
     @param alertTitle -> the alert title
     @param alertMessage -> the alert message
     @param handler -> the handler closure
     @param controller -> the UIViewController
     */
    class func showAlert(alertTitle : String, alertMessage : String, handler : ((UIAlertAction!) -> Void)!,
        controller : UIViewController) {
        var alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler : handler))
        dispatch_async(dispatch_get_main_queue()) {
            controller.presentViewController(alert, animated: true, completion: nil)
        }
    }

}