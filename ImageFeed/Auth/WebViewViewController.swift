//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//
import WebKit

class WebViewViewController: UIViewController {
    
    private let webView = WKWebView()
    
    // MARK: - Constants
    private enum NavConstants {
        static let backButtonLeftMargin: CGFloat = -16 // Сдвиг левее
        static let backButtonImageName = "nav_back_button"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupUI()
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(webView)
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: NavConstants.backButtonImageName),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        backButton.imageInsets = UIEdgeInsets(
            top: 0,
            left: NavConstants.backButtonLeftMargin, // Сдвигаем левее
            bottom: 0,
            right: 0
        )
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = YPColors.black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
