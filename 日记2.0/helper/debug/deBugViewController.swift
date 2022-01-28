//
//  deBugViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/28.
//

import UIKit

class deBugViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.image = image

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

}
