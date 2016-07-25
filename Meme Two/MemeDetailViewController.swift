//
//  MemeDetailViewController.swift
//  Meme Two
//
//  Created by Sugandha Naolekar on 7/25/16.
//  Copyright © 2016 icode. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var selectedMeme: Meme!
    @IBOutlet weak var detailImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImageView.image = selectedMeme.memedImage
        detailImageView.contentMode = .ScaleAspectFit
        
        
    }
}


