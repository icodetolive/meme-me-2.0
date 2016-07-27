//
//  MemeEditorViewController.swift
//  Meme Two
//
//  Created by Sugandha Naolekar on 7/25/16.
//  Copyright © 2016 icode. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var camera: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    //Define default textfield parameters
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3,
        NSBackgroundColorAttributeName: UIColor.clearColor()
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.grayColor()
        setupInitialView()
    }
    
    func setupInitialView() {
        
        //reset Image Picker View
        imagePickerView.image = nil
        
        setupTextFieldWithDefaultSettings(topText, withText: "TOP")
        setupTextFieldWithDefaultSettings(bottomText, withText: "BOTTOM")
        
        
        //Disable the share button initially
        shareButton.enabled = false
    }
    
    func setupTextFieldWithDefaultSettings(textField: UITextField, withText text: String) {
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.text = text
        textField.borderStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //subscribe to keyboard notifications
        subscribeToKeyboardNotifications()
        //shows camera source when available
        camera.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification  , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        //if editing is started in bottom textfield, frame moves up to avoid textfield being covered by the keyboard, if not already moved up
        if bottomText.isFirstResponder() && view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() && view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField.text == "TOP" || textField.text == "BOTTOM") {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func pickAnImageFromAlbums(sender: UIBarButtonItem) {
        
        saveImageFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        
        saveImageFromSource(UIImagePickerControllerSourceType.Camera)
    }
    
    func saveImageFromSource(source: UIImagePickerControllerSourceType) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = source
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        
        setupInitialView()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveMeme(memedImage: UIImage) {
        
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, image: imagePickerView.image!, memedImage: memedImage)
    }
    
    //Combine image and text using an image context to render the view hierarchy as a UIImage
    func generateMemedImage() -> UIImage {
        
        toolBar.hidden = true
        navigationBar.hidden = true
        
        //Render view as an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        navigationBar.hidden  = false
        return memedImage
    }
    
    @IBAction func shareImage(sender: UIBarButtonItem) {
        //generate memed image and pass it to activity controller
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.saveMeme(memedImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        //present view controller
        presentViewController(activityController, animated: true, completion: nil)
    }
}

