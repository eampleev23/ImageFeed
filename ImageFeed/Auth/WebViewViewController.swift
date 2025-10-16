//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//
import WebKit

class WebViewViewController: UIViewController {
    
    private let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    private func setupWebView() {
        // Настройка webView
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // Активация констрейнтов
        NSLayoutConstraint.activate([
            // Верхняя граница к Safe Area
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // Левая граница к Superview
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            // Правая граница к Superview
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Нижняя граница к Superview
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
