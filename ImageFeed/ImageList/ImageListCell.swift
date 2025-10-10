//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 10.10.2025.
//

import Foundation
import UIKit

final class ImageListCell: UITableViewCell {
    
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var picture: UIImageView!
    //    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet var publishDate: UILabel!
    //    @IBOutlet weak var picture: UIImageView!
//    @IBOutlet weak var publishDate: UILabel!
    
    static let reuseIdentifier = "ImageListCell"
    
}
