//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 10.10.2025.
//

import UIKit

final class ImageListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImageListCell"
    
    weak var delegate: ImageListCellDelegate?
    
    var currentImageURL: String?
    
    var photo: Photo?
    
    let picture: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .clear
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
    
    lazy var likeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let gradientHeight: CGFloat = 30
    private var gradientAdded = false
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        picture.kf.cancelDownloadTask()
        picture.image = nil
        publishDate.text = nil
        gradientAdded = false
        picture.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        picture.backgroundColor = .clear
        
        NSLayoutConstraint.deactivate(picture.constraints)
    }
    
    // MARK: - Public Methods
    
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
    
    // MARK: - Private Methods
    
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            picture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            picture.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            picture.topAnchor.constraint(equalTo: contentView.topAnchor),
            picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            picture.heightAnchor.constraint(greaterThanOrEqualToConstant: 212),
            
            publishDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            publishDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            likeBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            likeBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            likeBtn.widthAnchor.constraint(equalToConstant: 44),
            likeBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func updateLikeButtonAppearance() {
        let uiImage = isLiked ?
        UIImage(resource: Constants.likeImageResourse)
        : UIImage(resource: Constants.noLikeImageResourse)
        likeBtn.setImage(uiImage, for: .normal)
    }
    
    @objc private func likeButtonTapped(_ sender: Any) {
        guard let photo else {return}
        delegate?.imagesListCellDidTapLike(self, photoID: photo.id, isLikeToSet: !isLiked)
    }
}

// MARK: - Constants

private extension ImageListCell {
    enum Constants {
        static let likeImageResourse: ImageResource = .activeSVG
        static let noLikeImageResourse: ImageResource = .noActiveSVG
    }
}
