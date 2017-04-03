//
//  ViewController.swift
//  MemeMe
//
//  Created by Baratta, Dominic on 10/31/16.
//  Copyright © 2016 Dominic Baratta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    struct Meme {
        var topText: String!
        var bottomText: String!
        var originalImage: UIImage!
        var memedImage: UIImage!
    }

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var controlToolbar: UIToolbar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup the buttons correctly
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        actionButton.isEnabled = false

        // Set the default meme text
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        configureTextFields(textField: topTextField)
        configureTextFields(textField: bottomTextField)
    }
    
    func configureTextFields(textField : UITextField) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: NSNumber(value: -3.0),
            ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if(bottomTextField.isFirstResponder) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    @IBAction func pickImagePhotoLibraryAction(_ sender: UIBarButtonItem) {
        pickImageFromSource(source: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func pickImageCameraAction(_ sender: UIBarButtonItem) {
        pickImageFromSource(source: UIImagePickerControllerSourceType.camera)
    }
    
    func pickImageFromSource(source : UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonAction(_ sender: UIBarButtonItem) {
        // Generate the mime image
        let image = generateMemedImage()
        
        // Setup the activity view controller and present it to the user
        let viewController = UIActivityViewController(activityItems: [image], applicationActivities: nil);
        viewController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems, activityError) in
            if !completed {
                // User clicked the cancel button. Do not save the meme.
                return
            }
            
            // Call the function to save the image.
            self.save(image: image)
        }

        self.present(viewController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            
            // Enable the action button
            actionButton.isEnabled = true
            
            // Dismiss the image picker
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func save(image:UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: image)
        UIImageWriteToSavedPhotosAlbum(meme.memedImage, nil, nil, nil)
    }
    
    func generateMemedImage() -> UIImage {
        // Hide all of the chrome we don't want in our meme
        controlToolbar.isHidden = true
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show the control toolbar again
        controlToolbar.isHidden = false
        
        return memedImage
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if ((textField.text == "TOP") || textField.text == "BOTTOM") {
           textField.text = ""
        }
    }
}

