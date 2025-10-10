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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
    }
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath ) {
        
        // Отображаем картинку если она есть
        let imageName = photosNames[indexPath.row]
        print("Пытаемся загрузить изображение: '\(imageName)'")
        
        if UIImage(named: imageName) != nil {
            print("Изображение '\(imageName)' найдено в бандле")
            cell.picture.image = UIImage(named: imageName)
        } else {
            print("Изображение '\(imageName)' НЕ найдено в бандле")
            // Установите заглушку
            cell.picture.image = UIImage(systemName: "photo")
        }
        
        cell.publishDate.text = dateFormatter.string(from: Date())
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
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
