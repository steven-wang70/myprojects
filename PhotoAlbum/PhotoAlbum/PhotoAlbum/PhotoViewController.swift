//
//  PhotoViewController.swift
//  PhotoAlbum
//
//  Created by Wang, Steven on 2018-11-22.
//  Copyright © 2018 Wang, Steven. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageToShow.image = UIImage(data: data!)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.tapDetected))
        singleTap.numberOfTapsRequired = 1

        imageToShow.isUserInteractionEnabled = true
        imageToShow.addGestureRecognizer(singleTap)
    }

    private var data: Data? = nil
    @IBOutlet weak var imageToShow: UIImageView!

    internal func setPhoto(_ data: Data) -> Void {
        self.data = data
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //Action
    @objc func tapDetected() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
