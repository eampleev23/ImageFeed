//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 09.10.2025.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosNames: [String] = Array(0..<20).map{ "\($0)" }
    private var heightCache: [IndexPath: CGFloat] = [:]
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath ) {
        
        // Номер строки совпадает с названием файла в моках
        let imageName = photosNames[indexPath.row]
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if let cacheHeight = heightCache[indexPath] {
            return cacheHeight
        }
        
        let imageName = photosNames[indexPath.row]
        let image = UIImage(named: imageName)
        
        // Вычисляем высоту изображения
        let imageViewHeight: CGFloat
        
        if let image = image {
            
            let tableViewWidth = tableView.frame.width
            let horizontalPadding: CGFloat = 16
            let availableWidth = tableViewWidth - (horizontalPadding * 2)
            
            let aspectRatio = image.size.height / image.size.width
            imageViewHeight = availableWidth * aspectRatio
            
        } else {
            
            imageViewHeight = 200 // или высота placeholder
        }
        
        let verticalPadding: CGFloat = 32
        let totalHeight = imageViewHeight + verticalPadding
        
        heightCache[indexPath] = totalHeight
        
        return totalHeight
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
