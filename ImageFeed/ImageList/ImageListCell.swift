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
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        isLiked.toggle()
    }
    
    static let reuseIdentifier = "ImageListCell"
    private var gradientAdded = false
    
    var isLiked: Bool = false {
        didSet{
            updateLikeButtonAppearance()
        }
    }
    
    private func updateLikeButtonAppearance() {
        let imageName = isLiked ? "ActiveSVG" : "NoActiveSVG"
        let image = UIImage(named: imageName)
        
        likeBtn.setImage(image, for: .normal)
    }
    
    func addGradientIfNeeded() {
        
        guard !gradientAdded, picture.bounds.width > 0 else { return }
        
        picture.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(
            x: 0,
            y: picture.bounds.height - 30,
            width: picture.bounds.width,
            height: 30
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientAdded = false
        isLiked = false
    }
    
    // В классе ImageListCell:
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Создаем отступы внутри ячейки
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        contentView.frame = contentView.frame.inset(by: insets)
    }
}
