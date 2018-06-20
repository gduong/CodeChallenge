//
//  ProfileModel.swift
//  PassportMobileChallenge
//
//  Created by Goc Duong on 6/20/18.
//  Copyright © 2018 SHC. All rights reserved.
//

import Foundation
class ProfileModel {
    var id: String? = ""
    var gender: String? = ""
    var name: String? = ""
    var age: Int? = 0
    var profileImageURL: String? = ""
    var hobbies: String? = ""
    
    init(id: String, gender: String, name: String, age: Int, profileImageURL: String, hobbies: String) {
        self.id = id
        self.gender = gender
        self.name = name
        self.age = age
        self.profileImageURL = profileImageURL
        self.hobbies = hobbies
    }
}
