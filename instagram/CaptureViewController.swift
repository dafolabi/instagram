//
//  CaptureViewController.swift
//  instagram
//
//  Created by Daniel Afolabi on 6/27/17.
//  Copyright © 2017 Daniel Afolabi. All rights reserved.
//

import UIKit
import Parse
import Fusuma

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FusumaDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textfield: UITextField!
    
    var postImage = UIImage(named: "imageName")
    var postCaption = ""
    
    let vc = UIImagePickerController()
    
    let missingCameraAlertController = UIAlertController(title: "Camera not available", message: "Please select upload from camera roll ", preferredStyle: .alert)
    let noneAlertController = UIAlertController(title: "None selected", message: "Please take a picture or select one from camera roll ", preferredStyle: .alert)
    
//    fusumaTintColor: UIColor // tint color
//    
//    fusumaBackgroundColor: UIColor // background color
//    
//    fusumaCropImage:Bool // default is true for cropping the image

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        vc.delegate = self
        vc.allowsEditing = true
        
        createAlertControllers()
//        vc.sourceType = UIImagePickerControllerSourceType.camera
        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            print("Camera is available 📸")
//            vc.sourceType = .camera
//        } else {
//            print("Camera 🚫 available so we will use photo library instead")
//            vc.sourceType = .photoLibrary
//        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        postImage = editedImage
        imageView.image =  editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didHitPostButton(_ sender: Any) {
        postCaption = textfield.text ?? ""
        if imageView.image != #imageLiteral(resourceName: "image_placeholder") {
            Post.postUserImage(image: imageView.image, withCaption: postCaption) { (status: Bool, error: Error?) in
                print("Sucessfully posted")
                self.imageView.image = #imageLiteral(resourceName: "image_placeholder")
                self.textfield.text = nil
                
                
                HomeViewController.newpost = true
                self.tabBarController?.selectedIndex = 0

//                self.performSegue(withIdentifier: "backToHome", sender: self)
            }
        } else {
            self.present(self.noneAlertController, animated: true)
            print("there was no image to post")
        }
    }
    
    @IBAction func didHitTakePictureButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            let fusuma = FusumaViewController()
            fusuma.delegate = self
            fusuma.hasVideo = true // If you want to let the users allow to use video.
            self.present(fusuma, animated: true, completion: nil)
           // vc.sourceType = .camera
           // self.present(vc, animated: true, completion: nil)
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            self.present(self.missingCameraAlertController, animated: true)
        }
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        switch source {
            
        case .camera:
            
            print("Image captured from Camera")
            
        case .library:
            
            print("Image selected from Camera Roll")
            
        default:
            
            print("Image selected")
        }
        
        imageView.image = image
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
        print("Number of selection images: \(images.count)")
        
        var count: Double = 0
        
        for image in images {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (3.0 * count)) {
                
                self.imageView.image = image
                print("w: \(image.size.width) - h: \(image.size.height)")
            }
            count += 1
        }
    }

    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("video completed and output to file: \(fileURL)")
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested",
                                      message: "Saving image needs to access your photo album",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                
                UIApplication.shared.openURL(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlertControllers() {
        missingCameraAlertController.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
        })
        noneAlertController.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
        })
    }
    
    @IBAction func didHitUploadButton(_ sender: Any) {
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)

    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! HomeViewController
//        vc.refresh()
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }

}
