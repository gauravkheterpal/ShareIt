//
//  ShareExtViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

/*!
 This is the view controller for composing sharing item.
 */

class ShareExtViewController: SLComposeServiceViewController, SFRestDelegate {
    
    let SIConfigurationItemViewID = "ConfigurationItemView"

    var attachment : NSItemProvider?
    
    var configItems : [SLComposeSheetConfigurationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 46.0/255.0, green: 140.0/255.0, blue: 212.0/255.0, alpha: 1.0)
      
        
        self.prepareConfigurationItems()

       // Check if Salesforce user is present
        if let userAccount = SIChatterModel.getSFUserAccount() {
            NSLog("Salesforce account username %@", userAccount.userName)
            SFUserAccountManager.sharedInstance().currentUser = userAccount
        } else {
            SIChatterModel.showAlert(alertTitle: "No Salesforce Account", alertMessage:
                "There is no Salesforce account configured. Please launch Chatter Share app to login and try again.",
                handler: {
                    (UIAlertAction) in
                    self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                },
                controller: self)
        }
    }

    /*!
     It prepares configuration items according to attachment type
     */
    func prepareConfigurationItems() {
        
        // Extract attachment
        if let inputItem = self.extensionContext!.inputItems[0] as? NSExtensionItem {
            if let attachments = inputItem.attachments as? [NSItemProvider] {
                if !attachments.isEmpty {
                    self.attachment = attachments[0]
                }
            }
        }

        // Prepare configuration items according to attachment type
        if (self.attachment != nil) {
            let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
            
            func createConfigurationItemController(item : SLComposeSheetConfigurationItem) {
                let controller = storyboard.instantiateViewController(withIdentifier: SIConfigurationItemViewID)
                    as! ShareExtConfigItemViewController
                controller.configurationItem = item
                controller.shareExtViewController = self
                item.tapHandler = {
                    () -> Void in
                    self.pushConfigurationViewController(controller)
                }
            }

            if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeURL as! String) {
                // URL attachment needs two configuration items:
                // - URL
                // - Link Name
                let urlItem = SLComposeSheetConfigurationItem()
                urlItem!.title = "URL"
                self.attachment!.loadItem(forTypeIdentifier: kUTTypeURL as! String, options: nil, completionHandler: {
                    (obj, error) in
                    if let url = obj as? NSURL {
                        urlItem!.value = url.absoluteString
                    }
                })
                let linkNameItem = SLComposeSheetConfigurationItem()
                linkNameItem!.title = "Link Name"
                linkNameItem!.value = self.contentText
                //createConfigurationItemController(linkNameItem)

                self.configItems = [urlItem, linkNameItem] as! [SLComposeSheetConfigurationItem]
            } else if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeImage as! String) {
                // Photo attachment needs one configuration item:
                // - Photo Title
                let photoTitleItem = SLComposeSheetConfigurationItem()
                photoTitleItem!.title = "Photo Title"
                photoTitleItem!.value = "Photo"
                //createConfigurationItemController(photoTitleItem)

                self.configItems = [photoTitleItem] as! [SLComposeSheetConfigurationItem]
            }
        }
    }

    /*!
     It checks if the content is valid or not.
     @return true if the content is valid, false otherwise
     */
    override func isContentValid() -> Bool {
        // Content text is required
        if self.contentText.isEmpty {
            return false
        }

        // Link Name is required
        if (self.attachment != nil && self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeURL as! String)) {
            
            // return self.configItems != nil && !self.configItems[1].value.isEmpty (Geeting error)
            return !self.configItems[1].value.isEmpty
        }

        // Photo Name is required
        if (self.attachment != nil && self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeImage as! String)) {

            return !self.configItems[0].value.isEmpty
            
        }

        return true
    }

    /*!
     It is called when user selected to post.
     */
    override func didSelectPost() {
        if (self.attachment != nil) {
            if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeURL as! String) {
                SIChatterModel.postFeedItemToChatterWall(feedMsg: self.contentText, withLink: self.configItems[0].value,
                    linkName: self.configItems[1].value, delegate: self)
            } else if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeImage as! String) {
                // Determine MIME type
                var mimeType = "application/octet-stream"
                guard var fileName = self.configItems[0].value else {super.didSelectPost(); return}
                if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeJPEG as! String) {
                    mimeType = "image/jpeg"
                    fileName = fileName + ".jpg"
                } else if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypePNG as! String) {
                    mimeType = "image/png"
                    fileName = fileName + ".png"
                } else if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeGIF as! String) {
                    mimeType = "image/gif"
                    fileName = fileName + ".gif"
                } else if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeBMP as! String) {
                    mimeType = "image/bmp"
                    fileName = fileName + ".bmp"
                } else if self.attachment!.hasItemConformingToTypeIdentifier(kUTTypeTIFF as! String) {
                    mimeType = "image/tiff"
                    fileName = fileName + ".tiff"
                }
                // Load photo content
                self.attachment!.loadItem(forTypeIdentifier: kUTTypeImage as! String, options: nil, completionHandler: {
                    (obj, error) in
                    
                    if let imageURL = obj as? NSURL {
                    
                        let imageData = NSData(contentsOf: imageURL as URL)
                        // Upload photo to Salesforce
                        SIChatterModel.uploadFile(fileName: fileName, fileContent: imageData!,
                            mimeType: mimeType, delegate: self)
                    }
                })
            } else {
                super.didSelectPost()
            }
        } else {
            super.didSelectPost()
        }
    }

    /*!
     Returns the configuration items.
     @return the configuration items
     */
    override func configurationItems() -> [Any]! {
        return configItems
    }

    /*!
     This delegate is called when a request has finished loading.
     @param request -> the request
     @param jsonResponse -> the response
     */
    func request(request : SFRestRequest, didLoadResponse jsonResponse : AnyObject)
    {
        if request.path.hasSuffix("/feed-items") {
            // Feed item post response
            SIChatterModel.showAlert(alertTitle: "Success", alertMessage:
                "The shared item has been successfully posted.",
                handler: {
                    (UIAlertAction) in
                    self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                },
                controller: self)
          
        } else {
            // File upload response, post feed item
//            SIChatterModel.postFeedItemToChatterWall(feedMsg: self.contentText,
//                                                     withExistingDocument: jsonResponse.object("id") as! String, delegate: self)
            SIChatterModel.postFeedItemToChatterWall(feedMsg: self.contentText,
                                                     withExistingDocument: jsonResponse.object(forKey: "id") as! String, delegate: self)
        }
    }

    /*!
     This delegate is called when a request has failed due to an error.
     @param request -> the request
     @param error -> the error
    */
    func request(request : SFRestRequest, didFailLoadWithError error : NSError) {
        showAlert(alertMessage: "Request to Salesforce failed.")
    }

    /*!
     This delegate is called when a request has be cancelled.
     @param request -> the request
     */
    func requestDidCancelLoad(request : SFRestRequest) {
        showAlert(alertMessage: "Request to Salesforce is cancelled.")
    }

    /*!
     This delegate is called when a request has timed out.
     @param request -> the request
     */
    func requestDidTimeout(request : SFRestRequest) {
        showAlert(alertMessage: "Request to Salesforce timeout.")
    }

    /*!
     This function is called to show error alert.
     @param message -> the alert message
     */
    func showAlert(alertMessage : String) {
        var alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler : nil))
        self.present(alert, animated: true, completion: nil)
    }
}
