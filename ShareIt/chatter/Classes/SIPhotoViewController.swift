//
//  SIPhotoViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//


import Foundation
import AssetsLibrary

/*!
 This is the view controller used to share photo.
 */

class SIPhotoViewController : SIChatterViewController,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var fileName: UITextField!

    @IBOutlet var message: UITextView!

    @IBOutlet var photoPreview: UIImageView!

    var originalImageFileName : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        view.addGestureRecognizer(tap)
        
        self.photoPreview.layer.borderColor = UIColor.grayColor().CGColor
        self.photoPreview.layer.borderWidth = 1.0
    }
    
    // It hides keyboard on tapping on screen
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    /*!
        It shares the photo to chatter wall
        @param sender -> the event sender
     */
    @IBAction func sharePhoto(sender: AnyObject) {
        var message = ""
        if fileName.text.isEmpty {
            message = message + "File name is required!\n"
        }
        if !(self.photoPreview.image != nil) {
            message = message + "Photo is required!\n"
        }
        if message.isEmpty {
            // Determine MIME type and data to send
            var mimeType : String
            var data : NSData
            if self.originalImageFileName!.hasSuffix(".jpg") {
                mimeType = "image/jpeg"
                data = UIImageJPEGRepresentation(self.photoPreview.image, 1.0)
            } else if self.originalImageFileName!.hasSuffix(".png") {
                mimeType = "image/png"
                data = UIImagePNGRepresentation(self.photoPreview.image)
            } else {
                mimeType = "image/jpeg"
                data = UIImageJPEGRepresentation(self.photoPreview.image, 1.0)
            }
            SIChatterModel.uploadFile(self.fileName.text, fileContent: data, mimeType: mimeType, delegate: self)
        } else {
            SIChatterModel.showErrorAlert(message, controller : self)
        }
    }

    /*!
     It selects photo from photo library.
     @param sender -> the event sender
     */
    @IBAction func selectPhoto(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    /*!
     This delegate is called when user selects a photo.
     @param imagePicker -> the image picker
     @param mediaInfo -> the media information of the chosen photo
     */
    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo mediaInfo: [NSObject : AnyObject]) {
        
        let selectedImage = mediaInfo[UIImagePickerControllerOriginalImage] as! UIImage
        self.photoPreview.image = selectedImage
        imagePicker.dismissViewControllerAnimated(true, completion:nil)
        let url = mediaInfo[UIImagePickerControllerReferenceURL] as! NSURL
        
        // Try to get the real file name using Asset Library Framework
        let library = ALAssetsLibrary()
        library.assetForURL(url,
            resultBlock: {
                (asset : ALAsset?) in
                self.fileName.text = asset!.defaultRepresentation().filename()
                self.originalImageFileName = self.fileName.text.lastPathComponent;
            },
            failureBlock: {
                (error : NSError?) in
                self.fileName.text = url.lastPathComponent
            }
        )
    }

    /*!
     This delegate is called when user cancels selected photo.
     @param imagePicker -> the image picker
     */
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion:nil)
    }

    /*!
     This delegate is called when a salesforce request has finished loading.
     @param request -> the request
     @param jsonResponse -> the response
     */
    override func request(request : SFRestRequest, didLoadResponse jsonResponse : AnyObject) {        super.request(request, didLoadResponse: jsonResponse)
        if !request.path.hasSuffix("/feed-items") {
            // File upload response, posts feed item
            SIChatterModel.postFeedItemToChatterWall(self.message.text,
                withExistingDocument: jsonResponse.objectForKey("id") as! String, delegate: self)
        }
    }
}