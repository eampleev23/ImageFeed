//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 12.10.2025.
//

import UIKit

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    var image: UIImage? {
        didSet{
            guard isViewLoaded else { return }
            setImageAndConfigureLayout()
        }
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // Базовая кастомизация
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .markupAsPDF
        ]
        
        // Настройка для iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
            popoverController.permittedArrowDirections = .any
            popoverController.backgroundColor = .systemBackground
        }
        
        // Стиль как в нативных приложениях
        if #available(iOS 13.0, *) {
            activityViewController.isModalInPresentation = true
        }
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Пока устанавливаем временные значения
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        
        imageView.image = image
        // Настраиваем распознаватель двойного тапа
        setupDoubleTapGesture()
        setImageAndConfigureLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerImage()
    }
    
    private func setupDoubleTapGesture() {
        doubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(_:))
        )
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: imageView)
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // Если уже увеличен - возвращаем к минимальному zoom
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // Увеличиваем в 2 раза относительно точки тапа
            let zoomScale = min(scrollView.maximumZoomScale, 2.0)
            let zoomRect = zoomRectForScale(
                scale: zoomScale,
                center: tapPoint
            )
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        // Размер zoomRect относительно scale
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        // Центрируем относительно точки тапа
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    private func setImageAndConfigureLayout() {
        imageView.image = image
        
        guard let image = image else { return }
        
        // Устанавливаем размер imageView равным размеру изображения
        imageView.frame = CGRect(origin: .zero, size: image.size)
        
        // Устанавливаем contentSize scrollView
        scrollView.contentSize = image.size
        
        // Вычисляем и устанавливаем подходящий zoom scale
        let scale = calculateScaleForImage(image)
        scrollView.zoomScale = scale
        
        // УСТАНАВЛИВАЕМ МИНИМАЛЬНЫЙ ZOOM РАВНЫМ ТЕКУЩЕМУ МАСШТАБУ
        // Теперь нельзя уменьшить изображение, можно только увеличить
        scrollView.minimumZoomScale = scale
        
        // Центрируем изображение
        centerImage()
    }
    
    private func calculateScaleForImage(_ image: UIImage) -> CGFloat {
        let viewSize = scrollView.bounds.size
        let imageSize = image.size
        
        let widthScale = viewSize.width / imageSize.width
        let heightScale = viewSize.height / imageSize.height
        
        // Выбираем минимальный scale, чтобы изображение полностью помещалось
        return min(widthScale, heightScale)
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0
        
        if imageViewSize.width < scrollViewSize.width {
            horizontalInset = (scrollViewSize.width - imageViewSize.width) / 2
        }
        
        if imageViewSize.height < scrollViewSize.height {
            verticalInset = (scrollViewSize.height - imageViewSize.height) / 2
        }
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

