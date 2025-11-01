//
//  ImageListCellDelegate.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 31.10.2025.
//

import UIKit

protocol ImageListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImageListCell, photoID: String, isLike: Bool)
}
