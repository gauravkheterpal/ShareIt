//
//  SIPhotoViewController.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//


import Foundation
import AssetsLibrary
import Photos

/*!
 This is the view controller used to share photo.
 */

class SIPhotoViewController : SIChatterViewController,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var fileName: UITextField!

    @IBOutlet var message: UITextView!

    @IBOutlet var photoPreview: UIImageView!

    let imagePicker = UIImagePickerController()
    
    var originalImageFileName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
                //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SIPhotoViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
        
        self.photoPreview.layer.borderColor = UIColor.gray.cgColor
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
    @IBAction func sharePhoto(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        var message = ""
        if !(fileName.text?.isEmpty != nil) {
            message = message + "File name is required!\n"
        }
        if !(self.photoPreview.image != nil) {
            message = message + "Photo is required!\n"
        }
        if message.isEmpty {
            // Determine MIME type and data to send
            var mimeType : String
            var data : Data
            if self.originalImageFileName!.hasSuffix(".jpg") {
                mimeType = "image/jpeg"
                data = UIImageJPEGRepresentation(self.photoPreview.image!, 1.0)!
            } else if self.originalImageFileName!.hasSuffix(".png") {
                mimeType = "image/png"
                data = UIImagePNGRepresentation(self.photoPreview.image!)!
            } else {
                mimeType = "image/jpeg"
                data = UIImageJPEGRepresentation(self.photoPreview.image!, 1.0)!
            }
            SIChatterModel.uploadFile(self.fileName.text!, fileContent: data, mimeType: mimeType, delegate: self)
        } else {
            SIChatterModel.showErrorAlert(message, controller : self)
        }
    }

    /*!
     It selects photo from photo library.
     @param sender -> the event sender
     */
    @IBAction func selectPhoto(_ sender: AnyObject) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.photoPreview.image = selectedImage
        imagePicker.dismiss(animated: true, completion:nil)
        let url = info[UIImagePickerControllerReferenceURL] as! URL
         // Try to get the real file name using Asset Library Framework
        let library = ALAssetsLibrary()
        
        library.asset(for: url,
                      resultBlock: {
                        (asset : ALAsset?) in
                        self.fileName.text = asset!.defaultRepresentation().filename()
                        self.originalImageFileName = self.fileName.text;
            },
                      failureBlock: {
                        (error : Error?) in
                        self.fileName.text = url.lastPathComponent
            }
        )
    }
    
    /*!
     This delegate is called when user cancels selected photo.
     @param imagePicker -> the image picker
     */
    func imagePickerControllerDidCancel(_ imagePicker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion:nil)
    }

    /*!
     This delegate is called when a salesforce request has finished loading.
     @param request -> the request
     @param jsonResponse -> the response
     */
    override func request(_ request : SFRestRequest, didLoadResponse jsonResponse : AnyObject) {
        
        super.request(request, didLoadResponse: jsonResponse)
        if !request.path.hasSuffix("/feed-items") {
            // File upload response, posts feed item
            SIChatterModel.postFeedItemToChatterWall(self.message.text,
                withExistingDocument: jsonResponse.object(forKey: "id") as! String, delegate: self)
        }
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
        }
    }
}
