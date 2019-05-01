//
//  ImageGrabViewController
//  DoorSign
//
//  Created by John Gallaugher on 4/28/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class ImageGrabViewController: UIViewController {
    
    @IBOutlet weak var grabbedImageView: UIImageView!
    var grabbedImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        grabbedImageView.image = grabbedImage
    }


}
