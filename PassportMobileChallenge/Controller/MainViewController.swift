//
//  MainViewController.swift
//  PassportMobileChallenge
//
//  Created by Goc Duong on 6/20/18.
//  Copyright © 2018 SHC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileDB = Database.database().reference().child("Profiles")
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.register(UINib(nibName: "CustomProfileCell", bundle: nil), forCellReuseIdentifier: "customProfileCell")
        
        hideAddProfileView()
        configureButtons()
        retrieveProfile()
        retrieveProfileList()
        configureTableView()
    }
    
    func configureButtons() {
        femaleBtn.setImage(UIImage(named: "female_normal"), for: .normal)
        femaleBtn.setImage(UIImage(named: "female_Selected"), for: .selected)
        maleBtn.setImage(UIImage(named: "male_Normal"), for: .normal)
        maleBtn.setImage(UIImage(named: "male_Selected"), for: .selected)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Main view, Filter, Sort, Add button actions
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    
    var profileDB: DatabaseReference!
    var profileList = [ProfileModel]()
    var isFemale: Bool = true
    
    @IBAction func filterClick(_ sender: UIButton) {
        switch (sender as AnyObject).tag {
        case 0:
            filterProfileDB(gender: "female")
        case 1:
            filterProfileDB(gender: "male")
        case 2:
            retrieveProfileList()
        default:
            retrieveProfileList()
        }
    }
    
    //tag 0 = age ascending, tag 1 = age descending
    //tag 2 = name ascending, tag 3 = name descending
    @IBAction func sortClick(_ sender: UIButton) {
        switch (sender as AnyObject).tag {
        case 0:
            profileList.sort(by: {$0.age! < $1.age!})

        case 1:
            profileList.sort(by: {$0.age! > $1.age!})

        case 2:
            profileList.sort(by: {$0.name! < $1.name!})

        case 3:
            profileList.sort(by: {$0.name! > $1.name!})

        default:
            profileList.sort(by: {$0.name! > $1.name!})
        }
        DispatchQueue.main.async {
            self.profileTableView.reloadData()
        }
    }
    
    @IBAction func removeSortClick(_ sender: UIButton) {
        retrieveProfileList()
    }
    
    @IBAction func addProfileClick(_ sender: Any) {
        showAddProfileView()
    }
    
    func showAddProfileView() {
        self.mainView.isUserInteractionEnabled = false
        self.view.bringSubview(toFront: overlayAddProfileView)
        self.mainView.alpha = 0.3
    }
    
    func hideAddProfileView() {
        self.mainView.alpha = 1.0
        mainView.isUserInteractionEnabled = true
        self.view.sendSubview(toBack: overlayAddProfileView)
        name.text = nil
        age.text = nil
        profileURL.text = nil
        hobbies.text = nil
    }
    
    func filterProfileDB(gender: String) {
        let query = profileDB.queryOrdered(byChild: "Gender").queryEqual(toValue: gender)
        query.observe(.value, with: {(snapshot) in
            self.profileList.removeAll()
            if let childrenSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in childrenSnapshots {
                    if let snapDict = snap.value as? NSDictionary {
                        let name = snapDict["Name"] as! String
                        let gender = snapDict["Gender"] as! String
                        let id = snapDict["Id"] as! String
                        let age = snapDict["Age"] as! Int
                        let profileImageURL = snapDict["ProfileImageURL"] as! String
                        let hobbies = snapDict["Hobbies"] as! String
                        
                        let profile = ProfileModel(id: id, gender: gender, name: name, age: age, profileImageURL: profileImageURL, hobbies: hobbies)
                        self.profileList.append(profile)
                    }
                }
            }
            DispatchQueue.main.async {
                self.profileTableView.reloadData()
            }
        })
    }
    
    //MARK: - Overlay view, add profile View
    @IBOutlet weak var overlayAddProfileView: UIView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var profileURL: UITextField!
    @IBOutlet weak var hobbies: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    
    @IBAction func closeOverlyClick(_ sender: UIButton) {
        hideAddProfileView()
    }
    @IBAction func genderClick(_ sender: UIButton) {
        if femaleBtn.isSelected == true {
            femaleBtn.isSelected = false
            maleBtn.isSelected = true
            isFemale = false            
        } else {
            femaleBtn.isSelected = true
            maleBtn.isSelected = false
            isFemale = true
        }
    }
    @IBAction func addSaveClick(_ sender: Any) {
        //save DB
        var gender = "male"
        if isFemale == true {
            gender = "female"
        }
        let key = profileDB.childByAutoId().key
        let isAgeNumeric = age.text!.isNumber
        
        if name.text != "" && age.text != ""  && isAgeNumeric && profileURL.text != "" && hobbies.text != "" {
            let profileDict: NSDictionary = ["Id": key, "Name": name.text!, "Age": Int(age.text!) ?? 0, "ProfileImageURL": profileURL.text!, "Hobbies": hobbies.text!, "Gender": gender]
            profileDB.child(key).setValue(profileDict) {
                (error, refs) in
                if error != nil
                {
                    print(error!)
                } else {
                    print("profile saved successfully!")
                    DispatchQueue.main.async {
                        self.hideAddProfileView()
                        self.profileTableView.reloadData()
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please input valid data.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProfileCell", for: indexPath) as! CustomProfileCell
        cell.name.text = profileList[indexPath.row].name!
        cell.gender.text = profileList[indexPath.row].gender!
        cell.hobbies.text = profileList[indexPath.row].hobbies!
        cell.age.text = "\(profileList[indexPath.row].age!)"
        if profileList[indexPath.row].gender! == "male" {
            cell.profileImageView.image = UIImage(named: "defaultMaleProfileImage")
            cell.cellView.backgroundColor = UIColor.blue
        } else {
            cell.profileImageView.image = UIImage(named: "defaultFemaleProfileImage")
            cell.cellView.backgroundColor = UIColor.magenta
        }
        getImageFromURL(profileList[indexPath.row].profileImageURL!, closure: { (image) in
            if let image = image {
                cell.profileImageView.image = image
            }})
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showProfileView", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileView" {
            let profileViewController = segue.destination as! ProfileViewController
            let indexPath = self.profileTableView.indexPathForSelectedRow!
            let row = indexPath.row
            profileViewController.profile = profileList[row]
        }
    }
    
    func configureTableView(){
        profileTableView.rowHeight = UITableViewAutomaticDimension
        profileTableView.estimatedRowHeight = 80.0
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
    
    //MARK: - Firebase Mehtods
    func retrieveProfile() {
        profileDB.observe(.childAdded, with: { snapshot in
            let snapshopProfileValue = snapshot.value as! NSDictionary
            let name = snapshopProfileValue["Name"] as! String
            let gender = snapshopProfileValue["Gender"] as! String
            let id = snapshopProfileValue["Id"] as! String
            let age = snapshopProfileValue["Age"] as! Int
            let profileImageURL = snapshopProfileValue["ProfileImageURL"] as! String
            let hobbies = snapshopProfileValue["Hobbies"] as! String
            
            let profile = ProfileModel(id: id, gender: gender, name: name, age: age, profileImageURL: profileImageURL, hobbies: hobbies)
            self.profileList.append(profile)
            DispatchQueue.main.async {
                self.profileTableView.reloadData()
            }
        })
    }
    
    func retrieveProfileList() {
        profileDB.observe(.value, with: {snapshot in
            self.profileList.removeAll()
            if let childrenSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in childrenSnapshots {
                    if let snapDict = snap.value as? NSDictionary {
                        let name = snapDict["Name"] as! String
                        let gender = snapDict["Gender"] as! String
                        let id = snapDict["Id"] as! String
                        let age = snapDict["Age"] as! Int
                        let profileImageURL = snapDict["ProfileImageURL"] as! String
                        let hobbies = snapDict["Hobbies"] as! String
                        
                        let profile = ProfileModel(id: id, gender: gender, name: name, age: age, profileImageURL: profileImageURL, hobbies: hobbies)
                        self.profileList.append(profile)
                        
                    }
                }
            }
            DispatchQueue.main.async {
                self.profileTableView.reloadData()
            }
            })
    }

}

extension String {
    var isNumber : Bool {
        guard self.count > 0
            else { return false}
        let numSet: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: numSet)
    }
}
