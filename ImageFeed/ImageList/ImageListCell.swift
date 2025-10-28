//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 10.10.2025.
//

import Foundation
import UIKit

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImageListCell"
    
    private let gradientHeight: CGFloat = 30
    
    private var gradientAdded = false
    
    
    private let likeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let picture: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    let publishDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        return label
    }()
    
    var isLiked: Bool = false {
        didSet {
            updateLikeButtonAppearance()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Picture
            picture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            picture.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            picture.topAnchor.constraint(equalTo: contentView.topAnchor),
            picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Publish Date
            publishDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            publishDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Like Button
            likeBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            likeBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            likeBtn.widthAnchor.constraint(equalToConstant: 44),
            likeBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .ypBlack
        contentView.backgroundColor = .ypBlack
        selectionStyle = .none
        
        contentView.addSubview(picture)
        contentView.addSubview(publishDate)
        contentView.addSubview(likeBtn)
        
        likeBtn.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selectionView
    }
    
    @objc private func likeButtonTapped(_ sender: Any) {
        isLiked.toggle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        picture.image = nil
        publishDate.text = nil
        gradientAdded = false
        isLiked = false
        picture.layer.sublayers?.removeAll { $0 is CAGradientLayer }
    }
    
    func addGradientIfNeeded() {
        
        guard !gradientAdded, picture.bounds.width > 0 else {
            print("[ImageListCell, addGradientIfNeeded]: градиент уже добавлен или bounds нулевые")
            return
        }
        
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
