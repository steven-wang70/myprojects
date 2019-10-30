//
//  PhotoItemViewCell.swift
//  PhotoAlbum
//
//  Created by Wang, Steven on 2018-11-22.
//  Copyright © 2018 Wang, Steven. All rights reserved.
//

import UIKit

class PhotoItemViewCell: UITableViewCell {
    internal var photoEntity: Photos? = nil
    private var viewController: BaseViewController? = nil

    internal func setPhoto(_ photo: Photos, _ viewController: BaseViewController) -> Void {
        photoEntity = photo
        pictureLabel.text = photoEntity?.title
        self.viewController = viewController
    }

    //MARK: Properties
    @IBOutlet weak var pictureLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func displayPhoto(_ sender: UIButton) {
        viewController?.displayPhoto(photoEntity!)
    }
}
