//
//  CustomProfileCell.swift
//  PassportMobileChallenge
//
//  Created by Goc Duong on 6/20/18.
//  Copyright © 2018 SHC. All rights reserved.
//

import UIKit

class CustomProfileCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var hobbies: UILabel!
    @IBOutlet weak var age: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
