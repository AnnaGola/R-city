//
//  CustomTVC.swift
//  R • city
//
//  Created by anna on 07.06.2022.
//

import UIKit

final class CustomTVC: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            self.imageOfPlace.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var viewCell: UIView! {
        didSet {
            self.viewCell.layer.shadowColor = UIColor.blue.cgColor
            self.viewCell.layer.shadowOpacity = 0.1
            self.viewCell.layer.shadowOffset = .zero
            self.viewCell.layer.shadowRadius = 10
            self.viewCell.layer.cornerRadius = 15
        }
    }
}
