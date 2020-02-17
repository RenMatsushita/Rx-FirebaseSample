//
//  MessageTableViewCell.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI

final class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    func update(with message: Message) {
        DispatchQueue.main.async {
            let storageReference = Storage.storage().reference().child("images/\(message.imageName)")
            self.iconImageView.sd_setImage(with: storageReference, placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
        nameLabel.text = message.name
        contentLabel.text = message.content
    }
    
    private func configure() {
        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2
        iconImageView.layer.borderColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        iconImageView.layer.borderWidth = 1
        iconImageView.clipsToBounds = true
    }
}
