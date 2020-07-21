//
//  ProfileViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/4/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SDWebImage

class ProfileViewController: UIViewController {

   
    @IBOutlet weak var currentUserPhoto: UIImageView!
    @IBOutlet weak var currentUserName: UILabel!
    @IBOutlet weak var logoutCurrentUser: UIButton!
    
    @IBAction func pressedLogoutUser(_ sender: Any) {
        let actionSheet = UIAlertController(title: "", message: "Logout?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: {[weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            //Log out Google
            GIDSignIn.sharedInstance()?.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    var currentUser = FirebaseAuth.Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        
        let path = "images/"+filename
        
        currentUserPhoto.contentMode = .scaleAspectFill
        currentUserPhoto.layer.borderColor = #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1)
        currentUserPhoto.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        currentUserPhoto.layer.borderWidth = 6
        currentUserPhoto.layer.cornerRadius = currentUserPhoto.width / 2
        currentUserPhoto.layer.masksToBounds = true
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.currentUserPhoto.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download URL: \(error)")
            }
        })
        
        currentUserName.text = UserDefaults.standard.value(forKey: "name") as? String
    }
}
