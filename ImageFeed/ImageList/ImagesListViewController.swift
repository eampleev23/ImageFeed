//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 09.10.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosNames: [String] = Array(0..<20).map{ "\($0)" }
    private let defaultCellHeight: CGFloat = 200
    
    private var heightCache: [IndexPath: CGFloat] = [:]
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.rowHeight = defaultCellHeight
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowSingleImage" {
            
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let image = UIImage(named: photosNames[indexPath.row])
            viewController.image = image
            
        } else {
            
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configCell(for cell: ImageListCell, with indexPath: IndexPath, isLiked: Bool ) {
        
        let imageName = photosNames[indexPath.row]
        cell.isLiked = isLiked
        
        if UIImage(named: imageName) != nil {
            
            cell.picture.image = UIImage(named: imageName)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                cell.addGradientIfNeeded()
            }
            
        } else {
            
            cell.picture.image = UIImage(systemName: "photo")
        }
        
        cell.publishDate.text = dateFormatter.string(from: Date())
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if let cacheHeight = heightCache[indexPath] {
            return cacheHeight
        }
        
        let imageName = photosNames[indexPath.row]
        let image = UIImage(named: imageName)
        
        let imageViewHeight: CGFloat
        
        if let image {
            
            let tableViewWidth = tableView.frame.width
            let horizontalPadding: CGFloat = 16
            let availableWidth = tableViewWidth - (horizontalPadding * 2)
            
            let aspectRatio = image.size.height / image.size.width
            imageViewHeight = availableWidth * aspectRatio
            
        } else {
            
            imageViewHeight = defaultCellHeight
        }
        
        let verticalPadding: CGFloat = 32
        let totalHeight = imageViewHeight + verticalPadding
        
        heightCache[indexPath] = totalHeight
        
        return totalHeight
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        let isLiked = indexPath.row % 2 == 0
        
        configCell(for: imageListCell, with: indexPath, isLiked: isLiked)
        return imageListCell
    }
    
}
