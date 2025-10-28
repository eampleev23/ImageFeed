//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 09.10.2025.
//

import UIKit

final class ImageListViewController: UIViewController {
    
    private enum ImageListConstants {
        static let photosNames: [String] = Array(0..<20).map{ "\($0)" }
        static let defaultCellHeight: CGFloat = 200
    }
    
    private lazy var tableView: UITableView = {
        print("[ImageListViewController, lazy tableView]: создаем tableView")
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = ImageListConstants.defaultCellHeight
        tableView.register(ImageListCell.self, forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var heightCache: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("[ImageListViewController, viewDidLoad]: началась настройка контроллера")
        
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        print("[ImageListViewController, setupView]: добавляем tableView на view")
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        print("[ImageListViewController, setupConstraints]: настраиваем констрейнты tableView")
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showSingleImageViewController(for indexPath: IndexPath) {
        print("[ImageListViewController, showSingleImageViewController]: показываем изображение для indexPath \(indexPath)")
        let singleImageVC = SingleImageViewController()
        let image = UIImage(named: ImageListConstants.photosNames[indexPath.row])
        singleImageVC.image = image
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }
    
    private func configCell(for cell: ImageListCell, with indexPath: IndexPath, isLiked: Bool ) {
        print("[ImageListViewController, configCell]: настраиваем ячейку для indexPath \(indexPath)")
        
        let imageName = ImageListConstants.photosNames[indexPath.row]
        cell.isLiked = isLiked
        
        if UIImage(named: imageName) != nil {
            cell.picture.image = UIImage(named: imageName)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                cell.addGradientIfNeeded()
            }
        } else {
            print("[ImageListViewController, configCell]: изображение \(imageName) не найдено")
            cell.picture.image = UIImage(systemName: "photo")
        }
        
        cell.publishDate.text = dateFormatter.string(from: Date())
    }
}

extension ImageListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("[ImageListViewController, tableView(didSelectRowAt)]: выбрана ячейка \(indexPath)")
        showSingleImageViewController(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("[ImageListViewController, tableView(heightForRowAt)]: вычисляем высоту для ячейки \(indexPath)")
        
        if let cacheHeight = heightCache[indexPath] {
            print("[ImageListViewController, tableView(heightForRowAt)]: используем кэшированную высоту \(cacheHeight)")
            return cacheHeight
        }
        
        let imageName = ImageListConstants.photosNames[indexPath.row]
        let image = UIImage(named: imageName)
        
        let imageViewHeight: CGFloat
        
        if let image {
            let tableViewWidth = tableView.frame.width
            let horizontalPadding: CGFloat = 0
            let availableWidth = tableViewWidth - (horizontalPadding * 2)
            
            let aspectRatio = image.size.height / image.size.width
            imageViewHeight = availableWidth * aspectRatio
            print("[ImageListViewController, tableView(heightForRowAt)]: вычисленная высота изображения \(imageViewHeight)")
        } else {
            imageViewHeight = ImageListConstants.defaultCellHeight
        }
        
        let verticalPadding: CGFloat = 4
        let totalHeight = imageViewHeight + verticalPadding
        
        heightCache[indexPath] = totalHeight
        print("[ImageListViewController, tableView(heightForRowAt)]: итоговая высота ячейки \(totalHeight)")
        
        return totalHeight
    }
}

extension ImageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = ImageListConstants.photosNames.count
        print("[ImageListViewController, tableView(numberOfRowsInSection)]: количество ячеек \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("[ImageListViewController, tableView(cellForRowAt)]: создаем ячейку для \(indexPath)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            print("[ImageListViewController, tableView(cellForRowAt)]: ошибка - не удалось привести ячейку к ImageListCell")
            return UITableViewCell()
        }
        
        let isLiked = indexPath.row % 2 == 0
        configCell(for: imageListCell, with: indexPath, isLiked: isLiked)
        print("[ImageListViewController, tableView(cellForRowAt)]: ячейка успешно настроена")
        
        return imageListCell
    }
}
