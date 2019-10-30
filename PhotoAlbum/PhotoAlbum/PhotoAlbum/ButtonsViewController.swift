//
//  ButtonsViewController.swift
//  PhotoAlbum
//
//  Created by Wang, Steven on 2018-11-22.
//  Copyright © 2018 Wang, Steven. All rights reserved.
//

import UIKit

class ButtonsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addFromLibrary(_ sender: UIButton) {
        let baseView = self.parent as! BaseViewController
        baseView.addFromLibrary()
    }
    
    @IBAction func addFromCamera(_ sender: UIButton) {
        let baseView = self.parent as! BaseViewController
        baseView.addFromCamera()
    }

    @IBAction func updateFromLibraray(_ sender: UIButton) {
        let baseView = self.parent as! BaseViewController
        baseView.updateFromLibrary()
    }
    
    @IBAction func updateFromCamera(_ sender: UIButton) {
        let baseView = self.parent as! BaseViewController
        baseView.updateFromCamera()
    }
    
    @IBAction func deletePhoto(_ sender: UIButton) {
        let baseView = self.parent as! BaseViewController
        baseView.deletePhoto()
    }
    
}
