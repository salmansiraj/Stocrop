//
//  UserTableViewController.swift
//  Instagram
//
//  Created by salman siraj on 1/22/19.
//  Copyright © 2019 salman siraj. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames : [String] = []
    var objectIds : [String] = []
    var isFollowing = [String:Bool]()
    
    
    var refresher: UIRefreshControl = UIRefreshControl()

    @IBAction func logoutUser(_ sender: Any) {
        
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
    }
    
    @objc func updateTable() {
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username!) // for users to not follow themselves
        
        query?.findObjectsInBackground(block: { (users, error) in
            if error != nil {
                
                print(error.debugDescription)
                
            } else if let users = users {
                
                for object in users {
                    if let user = object as? PFUser {
                        if let username = user.username {
                            
                            if let objectId = user.objectId {
                                
                                let usernameArray = username.components(separatedBy: "@")
                                
                                self.usernames.append(usernameArray[0])
                                self.objectIds.append(objectId)
                                
                                let query = PFQuery(className: "Following")
                                
                                // Checking if they are following user thats being ran
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
                                query.whereKey("following", equalTo: objectId)
                                
                                query.findObjectsInBackground(block: { (objects, error) in
                                    
                                    if let objects = objects {
                                        if objects.count > 0 {
                                            
                                            self.isFollowing[objectId] = true
                                            
                                        } else {
                                            self.isFollowing[objectId] = false
                                        }
                                        
                                    }
                                    
                                    if self.usernames.count == self.isFollowing.count {
                                        self.tableView.reloadData() // reload checked followers
                                        self.refresher.endRefreshing()
                                        
                                    }
                                    
                                })
                                
                            }
                            
                        }
                    }
                }
            }
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        // Add a target
        refresher.addTarget(self, action: #selector(UserTableViewController.updateTable), for: UIControl.Event.valueChanged)
        
        tableView.addSubview(refresher)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = usernames[indexPath.row] // inserting items in array
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            
            if followsBoolean {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            
            if followsBoolean { // if we do follow them, then unfollow
                
                // Update isFollowing on app from the parseServer info
                isFollowing[objectIds[indexPath.row]] = false
                
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                
                let query = PFQuery(className: "Following")
                
                // Checking if they are following user thats being ran
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if let objects = objects {
                        
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            
            } else {
                
                isFollowing[objectIds[indexPath.row]] = true
                
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                // Updating checking of followings on database
                let following = PFObject(className: "Following")
                
                following["follower"] = PFUser.current()?.objectId
                following["following"] = objectIds[indexPath.row]
                following.saveInBackground()
                
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
