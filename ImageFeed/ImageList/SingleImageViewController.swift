import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: String? {
        didSet {
            guard isViewLoaded else { return }
            loadLargeImage()
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .singleImgBackBtn), for: .normal)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .singleImageSharingButton), for: .normal)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .ypWhite
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    private var savedZoomState: (scale: CGFloat, contentOffset: CGPoint)?
    private var isSharing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDoubleTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLargeImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isSharing, imageView.image != nil {
            configureScrollViewWithImage(imageView.image!)
        }
        centerImage()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        view.addSubview(loadingIndicator)
        
        scrollView.delegate = self
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        shareButton.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -51),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadLargeImage() {
        guard let imageURLString = imageURL, let url = URL(string: imageURLString) else {
            print("[SingleImageViewController]: Неверный URL для большого изображения")
            showErrorAlert()
            return
        }
        
        loadingIndicator.startAnimating()
        shareButton.isHidden = true
        imageView.isHidden = true
        
        imageView.kf.setImage(
            with: url,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.loadingIndicator.stopAnimating()
            
            switch result {
            case .success(let value):
                self.shareButton.isHidden = false
                DispatchQueue.main.async {
                    self.configureScrollViewWithImage(value.image)
                    self.imageView.isHidden = false
                }
                
            case .failure(let error):
                print("[SingleImageViewController] Ошибка загрузки изображения: \(error)")
                self.showErrorAlert()
                self.imageView.isHidden = false
            }
        }
    }
    
    private func configureScrollViewWithImage(_ image: UIImage) {
        if isSharing { return }
        
        let imageSize = image.size
        let viewSize = view.bounds.size
        
        guard viewSize.width > 0 && viewSize.height > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.configureScrollViewWithImage(image)
            }
            return
        }
        
        let widthRatio = viewSize.width / imageSize.width
        let heightRatio = viewSize.height / imageSize.height
        let minScale = min(widthRatio, heightRatio)
        
        let scaledWidth = imageSize.width * minScale
        let scaledHeight = imageSize.height * minScale
        
        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: scaledWidth,
            height: scaledHeight
        )
        
        scrollView.contentSize = CGSize(width: scaledWidth, height: scaledHeight)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minScale
        
        centerImage()
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить изображение",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadLargeImage()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func setupDoubleTapGesture() {
        doubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap)
        )
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {
            print("[SingleImageViewController] Ошибка: изображение отсутствует")
            return
        }
        
        isSharing = true
        savedZoomState = (scrollView.zoomScale, scrollView.contentOffset)
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        activityViewController.excludedActivityTypes = [
            .addToReadingList, .assignToContact, .openInIBooks, .markupAsPDF
        ]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        activityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.isSharing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self?.restoreZoomState()
            }
        }
        
        present(activityViewController, animated: true)
    }
    
    private func restoreZoomState() {
        guard let savedState = savedZoomState else { return }
        
        UIView.animate(withDuration: 0.25) {
            self.scrollView.zoomScale = savedState.scale
            self.scrollView.contentOffset = savedState.contentOffset
            self.centerImage()
        }
        
        savedZoomState = nil
    }
    
    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: imageView)
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let zoomScale = min(scrollView.maximumZoomScale, scrollView.zoomScale * 2.0)
            let zoomRect = zoomRectForScale(scale: zoomScale, center: tapPoint)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        guard scrollViewSize.width > 0 && scrollViewSize.height > 0 else { return }
        
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0
        
        if imageViewSize.width < scrollViewSize.width {
            horizontalInset = (scrollViewSize.width - imageViewSize.width) / 2.0
        }
        
        if imageViewSize.height < scrollViewSize.height {
            verticalInset = (scrollViewSize.height - imageViewSize.height) / 2.0
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
