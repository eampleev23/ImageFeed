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
    @IBOutlet var publishDate: UILabel!
    
    static let reuseIdentifier = "ImageListCell"
    
    private let gradientHeight:CGFloat = 30
    
    private var gradientAdded = false
    
    var isLiked: Bool = false {
        didSet{
            updateLikeButtonAppearance()
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        isLiked.toggle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientAdded = false
        isLiked = false
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selectionView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        contentView.frame = contentView.frame.inset(by: insets)
    }
    
    func addGradientIfNeeded() {
        
        guard !gradientAdded, picture.bounds.width > 0 else { return }
        
        picture.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(
            x: 0,
            y: picture.bounds.height - gradientHeight,
            width: picture.bounds.width,
            height: gradientHeight
        )
        
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.5).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor
        ]
        
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.zPosition = 1000
        
        picture.layer.addSublayer(gradientLayer)
        gradientAdded = true
    }
    
    private func updateLikeButtonAppearance() {
        let imageName = isLiked ? "ActiveSVG" : "NoActiveSVG"
        let image = UIImage(named: imageName)
        
        likeBtn.setImage(image, for: .normal)
    }
}
