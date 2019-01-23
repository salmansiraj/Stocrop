//
//  ViewController.swift
//  Instagram
//
//  Created by salman siraj on 1/22/19.
//  Copyright © 2019 salman siraj. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var signupmodeActive = true
    

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signupOrLoginbtn: UIButton!
    @IBOutlet weak var switchLoginModebtn: UIButton!
    
    
    func displayAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            print("Successfully logged in")
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func signuporLogin(_ sender: Any) {
        if (email.text == "" || password.text == "") {
            
            self.displayAlert(title: "Error in form", message: "Please enter an email and password")
            
        } else {
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            activityIndicator.center = self.view.center
            
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            // To stop from doing anything else after paused
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if (signupmodeActive) {
                
                // SIGNUP Create Account Via Parse
                
                let user = PFUser()
                user.username = email.text
                user.password = password.text
                user.email = email.text
                
                user.signUpInBackground { (success, error) in
                    
                    // Stop loading enimation if success
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if let error = error {
                        
                        self.displayAlert(title: "Error in sign up", message: error.localizedDescription)
                        // Show the errorString somewhere and let the user try again.
                    } else {
                        print("signed up!")
                        // Hooray! Let them use the app now.
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                }
            } else {

                // LOGIN SECTION
                
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!) { (user, error) in
                    
                    // Stop loading enimation if success
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if user != nil {
                        // Do stuff after successful login.
                        print("Login successful")
                         self.performSegue(withIdentifier: "showUserTable", sender: self)
                        
                    } else {
                        
                        var errorText = "Unknown error: Please try again"
                        
                        if let error = error {
                            
                            errorText = error.localizedDescription
                        }
                        // The login failed. Check error to see why.
                        self.displayAlert(title: "Could not sign you up", message: errorText)
                    }
                }
            }
        }
    }
    
    @IBAction func switchLoginMode(_ sender: Any) {
        if (signupmodeActive == true) {
            
            signupmodeActive = false // login mode now
            signupOrLoginbtn.setTitle("Log In", for: [])
            switchLoginModebtn.setTitle("Sign Up", for: [])
            
        } else {
            
            signupmodeActive = true // login mode now
            signupOrLoginbtn.setTitle("Sign Up", for: [])
            switchLoginModebtn.setTitle("Log In", for: [])
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
             performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        self.navigationController?.navigationBar.isHidden = true // Hide top bar when going back to login view controller
    
    }
    
}




/// NOTES

/*
 // Saving parse objects
 
 let comment = PFObject(className: "Comment")
 
 comment["text"] = "Nice shot!"
 
 comment.saveInBackground {
 (success, error) in
 if (success) {
 print("Save successful!")
 } else {
 print("Save failed")
 }
 }
 */

/*
 // Retrieving parse objects
 let query = PFQuery(className: "Comment")
 
 query.getObjectInBackground(withId: "GAwWQzfRM7") { (object, errror) in
 
 if let comment = object {
 comment["text"] = "Awful shot!"
 
 comment.saveInBackground(block: { (success, error) in
 if (success) {
 print("update sucessful")
 } else {
 print("not successful")
 }
 })
 }
 }
 */

/*
 // Tweet example
 let tweet  = PFObject(className: "tweet")
 
 tweet["text"] = "I love pickles"
 
 tweet.saveInBackground { (success, error) in
 if (success) {
 print(tweet["text"])
 } else {
 print("failed")
 }
 }
 */

