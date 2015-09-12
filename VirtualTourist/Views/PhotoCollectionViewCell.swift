//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 12.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        if imageView.image == nil {
            
            activityIndicatorView.startAnimating()
        }
    }
}
