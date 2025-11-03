//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 09.10.2025.
//

import UIKit
import Kingfisher

final class ImageListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let imageListService = ImagesListService()
    private var observer: NSObjectProtocol?
    private var isInitialLoading = true
    private var heightCache: [IndexPath: CGFloat] = [:]
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = Constants.defaultCellHeight
        tableView.register(ImageListCell.self, forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupObserver()
        
        ImageFeedProgressHUD.show()
        imageListService.fetchPhotosNextPage()
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        ImageFeedProgressHUD.dismiss()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            guard let self else { return }
            
            let type = notification.userInfo?["type"] as? String
            
            switch type {
            case "photosLoaded":
                ImageFeedProgressHUD.dismiss()
                self.isInitialLoading = false
                self.updateTableViewAnimated()
                
            default:
                self.updateTableViewAnimated()
            }
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = imageListService.photos.count
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    private func loadNextPageIfNeeded(for indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            ImageFeedProgressHUD.show()
            imageListService.fetchPhotosNextPage()
        }
    }
    
    private func showSingleImageViewController(for indexPath: IndexPath) {
        guard indexPath.row < imageListService.photos.count else { return }
        
        let singleImageVC = SingleImageViewController()
        let photo = imageListService.photos[indexPath.row]
        singleImageVC.imageURL = photo.largeImageURL
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }
    
    private func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        guard indexPath.row < imageListService.photos.count else { return }
        
        let photo = imageListService.photos[indexPath.row]
        cell.photo = photo
        cell.isLiked = photo.isLiked
        cell.publishDate.text = formatDate(photo.createdAt)
        loadImageForCell(cell, photo: photo)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
    }
    
    private func loadImageForCell(_ cell: ImageListCell, photo: Photo) {
        guard let url = URL(string: photo.thumbImageURL) else {
            cell.picture.image = nil
            return
        }
        
        cell.photo = photo
        
        cell.currentImageURL = photo.thumbImageURL
        cell.picture.kf.indicatorType = .none
        
        let placeholderImage: UIImage? = {
            let size = CGSize(width: 300, height: 212)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            return renderer.image { context in
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 16)
                path.addClip()
                UIColor.ypWhite.withAlphaComponent(0.5).setFill()
                context.fill(CGRect(origin: .zero, size: size))
                
                let stubImage = UIImage(resource: .feedImageStub)
                let imageSize = CGSize(
                    width: stubImage.size.width / 3,
                    height: stubImage.size.height / 3
                )
                let imageRect = CGRect(
                    x: (size.width - imageSize.width) / 2,
                    y: (size.height - imageSize.height) / 2,
                    width: imageSize.width,
                    height: imageSize.height
                )
                stubImage.draw(in: imageRect)
            }
        }()
        
        cell.picture.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(_):
                if cell.currentImageURL == photo.thumbImageURL {
                    DispatchQueue.main.async {
                        cell.addGradientIfNeeded()
                    }
                }
            case .failure(_):
                if cell.currentImageURL == photo.thumbImageURL {
                    DispatchQueue.main.async {
                        cell.picture.image = nil
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ImageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImageViewController(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < imageListService.photos.count else {
            return Constants.defaultCellHeight
        }
        
        if let cacheHeight = heightCache[indexPath] {
            return cacheHeight
        }
        
        let photo = imageListService.photos[indexPath.row]
        let imageSize = photo.size
        
        let tableViewWidth = tableView.frame.width
        let horizontalPadding: CGFloat = 0
        let availableWidth = tableViewWidth - (horizontalPadding * 2)
        
        let aspectRatio = imageSize.height / imageSize.width
        let imageViewHeight = availableWidth * aspectRatio
        
        let verticalPadding: CGFloat = 4
        let totalHeight = imageViewHeight + verticalPadding
        
        heightCache[indexPath] = totalHeight
        return totalHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadNextPageIfNeeded(for: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

// MARK: - UITableViewDataSource

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImageListCell else { return UITableViewCell() }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - ImageListCellDelegate

extension ImageListViewController: ImageListCellDelegate {
    
    func imagesListCellDidTapLike(_ cell: ImageListCell, photoID: String, isLikeToSet: Bool) {
        cell.likeBtn.isEnabled = false
        imageListService.changeLike(photoID: photoID, isLikeToSet: isLikeToSet) { result in
            DispatchQueue.main.async {
                cell.likeBtn.isEnabled = true
                switch result{
                case .success:
                    if let index = self.imageListService.photos.firstIndex(where: { $0.id == photoID }) {
                        // Обновляем состояние в данных
                        self.imageListService.photos[index].isLiked = isLikeToSet
                        cell.isLiked = isLikeToSet
                    }
                case .failure(let error):
                    print("[ImageListViewController: ImageListCellDelegate, imagesListCellDidTapLike], ошибка: \(error)..")
                    cell.isLiked = !isLikeToSet
                }
            }
        }
    }
}

// MARK: - Constants

private extension ImageListViewController {
    enum Constants {
        static let defaultCellHeight: CGFloat = 200
    }
}
