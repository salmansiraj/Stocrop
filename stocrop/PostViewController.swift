//
//  PostViewController.swift
//  Instagram
//
//  Created by salman siraj on 1/22/19.
//  Copyright © 2019 salman siraj. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBOutlet weak var comment: UITextField!
    
    
    func displayAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            print("Successfully logged in")
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func shareBtn(_ sender: Any) {
        
        if let image = imageToPost.image {
            
            let post = PFObject(className: "Post")
            
            post["message"] = comment.text
            post["userid"] = PFUser.current()?.objectId
            
            if let imageData = image.pngData() {
                
                let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                
                activityIndicator.center = self.view.center
                
                activityIndicator.hidesWhenStopped = true
                activityIndicator.style = UIActivityIndicatorView.Style.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                
                // To stop from doing anything else after paused
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                let imageFile = PFFileObject(name: "image.png", data: imageData)
                
                post["imageFile"] = imageFile
                
                post.saveInBackground(block: { (success, error) in
                    
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if success {
                        self.displayAlert(title: "Image Posted!", message: "Your image has been posted successfully")
                        
                        // clear out the posting area
                        self.comment.text = ""
                        self.imageToPost.image = nil
                        
                    } else {
                        
                        self.displayAlert(title: "Image Could Not be Posted", message: "Please try again")
                    }
                    
                    
                })
            }
            
        }
        
        
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.allowsEditing = false
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageToPost.image = image
        } else {
            print("error")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
