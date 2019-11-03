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

    @IBOutlet var message: UITextField!

    @IBOutlet var photoPreview: UIImageView!

    var originalImageFileName : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        self.photoPreview.layer.borderColor = UIColor.gray.cgColor
        self.photoPreview.layer.borderWidth = 1.0
    }
    
    // It hides keyboard on tapping on screen
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    /*!
        It shares the photo to chatter wall
        @param sender -> the event sender
     */
    @IBAction func sharePhoto(sender: AnyObject) {
        var message = ""
        if fileName.text?.isEmpty ?? true {
            message = message + "File name is required!\n"
        }
        if !(self.photoPreview.image != nil) {
            message = message + "Photo is required!\n"
        }
        if message.isEmpty {
            // Determine MIME type and data to send
            var mimeType : String
            var data : Data?
            if self.originalImageFileName!.hasSuffix(".jpg") {
                mimeType = "image/jpeg"
                data = self.photoPreview.image!.jpegData(compressionQuality: 1.0)
            } else if self.originalImageFileName!.hasSuffix(".png") {
                mimeType = "image/png"
                data = self.photoPreview.image!.pngData()
            } else {
                mimeType = "image/jpeg"
                data = self.photoPreview.image!.jpegData(compressionQuality: 1.0)
            }
            if let dataToSend = data as? NSData {
                SIChatterModel.uploadFile(fileName: self.fileName.text!, fileContent: dataToSend, mimeType: mimeType, delegate: self)
            }
        } else {
            SIChatterModel.showErrorAlert(alertMessage: message, controller : self)
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
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    /*!
     This delegate is called when user selects a photo.
     @param imagePicker -> the image picker
     @param mediaInfo -> the media information of the chosen photo
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.photoPreview.image = selectedImage
        picker.dismiss(animated: true, completion:nil)
        let url = info[UIImagePickerController.InfoKey.referenceURL] as! URL
        
        // Try to get the real file name using Asset Library Framework
        let library = ALAssetsLibrary()
        library.asset(for: url, resultBlock: { (asset) in
            self.fileName.text = asset!.defaultRepresentation().filename()
            self.originalImageFileName = asset?.defaultRepresentation()?.url()?.lastPathComponent
        }) { (error) in
            self.fileName.text = url.lastPathComponent
        }
    }

    /*!
     This delegate is called when user cancels selected photo.
     @param imagePicker -> the image picker
     */
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion:nil)
    }

    /*!
     This delegate is called when a salesforce request has finished loading.
     @param request -> the request
     @param jsonResponse -> the response
     */
    override func request(_ request: SFRestRequest!, didLoadResponse dataResponse: Any!) {
        super.request(request, didLoadResponse: dataResponse)
        guard let jsonResponse = dataResponse as? NSDictionary else { return }
                if !request.path.hasSuffix("/feed-items") {
                    // File upload response, posts feed item
        //            SIChatterModel.postFeedItemToChatterWall(feedMsg: self.message.text,
        //                withExistingDocument: jsonResponse.objectForKey("id") as! String, delegate: self)
                    SIChatterModel.postFeedItemToChatterWall(feedMsg: self.message.text ?? "",
                                                             withExistingDocument: jsonResponse.object(forKey: "id") as! String, delegate: self)
                }
    }
}
