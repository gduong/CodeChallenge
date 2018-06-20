//
//  ProfileViewController.swift
//  PassportMobileChallenge
//
//  Created by Goc Duong on 6/20/18.
//  Copyright © 2018 SHC. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var hobbies: UILabel!
    @IBOutlet weak var updateHobbies: UITextField!
    
    var profile: ProfileModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if profile.gender! == "male" {
            profileImageView.image = UIImage(named: "defaultMaleProfileImage")
        } else {
            profileImageView.image = UIImage(named: "defaultFemaleProfileImage")
        }
        getImageFromURL(profile.profileImageURL!, closure: { (image) in
            if let image = image {
                self.profileImageView.image = image
            }})
        gender.text = profile.gender!
        name.text = profile.name!
        age.text = "\(profile.age!)"
        hobbies.text = profile.hobbies!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func deleteProfileClick(_ sender: Any) {
        let profileDB = Database.database().reference().child("Profiles/\(profile.id!)")
        profileDB.removeValue(){
            (error:Error?, re:DatabaseReference) in
            
            if error != nil {
                print("faile delete")
            } else {
                self.profile = ProfileModel(id: "", gender: "", name: "", age: 0, profileImageURL: "", hobbies: "")
                self.gender.text = nil
                self.name.text = nil
                self.age.text = nil
                self.hobbies.text = nil
                print("delete successfully")
                
            }
        }
    }
    @IBAction func updateHobbiesClick(_ sender: UIButton) {
        if profile.id != ""  && updateHobbies.text != "" {
            let profileDB = Database.database().reference().child("Profiles/\(profile.id!)")
            profileDB.updateChildValues(["Hobbies": updateHobbies.text!, "Gender": profile.gender!, "Name": profile.name!, "Age": profile.age!, "Id": profile.id!, "ProfileImageURL": profile.profileImageURL!]){
                (error:Error?, re:DatabaseReference) in
                
                if error != nil {
                    print("faile update")
                } else {
                    print("update successfully")
                    DispatchQueue.main.async {
                        self.profile.hobbies = self.updateHobbies.text!
                        self.hobbies.text = self.profile.hobbies!
                    }
                }
            }
        } else {
            var message = "Please input hobbies."
            if profile.id! == "" {
                message = "Profile doesn't exist, back to main page and add profile!"
            }
            let alertController = UIAlertController(title: "Update Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getImageFromURL(_ urlString: String, closure: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil, response != nil, data != nil else {
                return closure(nil)
            }
            DispatchQueue.main.async {
                closure(UIImage(data: data!))
            }
        }; task.resume()
    }

}
