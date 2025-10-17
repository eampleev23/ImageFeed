//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//
@preconcurrency import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    private let webView = WKWebView()
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Constants
    private enum NavConstants {
        static let backButtonLeftMargin: CGFloat = -16 // Сдвиг левее
        static let backButtonImageName = "nav_back_button"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupWebView()
        setupUI()
        setupNavigationBar()
        loadAuthView()
    }
    
    private func loadAuthView(){
        
        guard var urlComponents = URLComponents(
            string: WebViewConstants.unsplashAuthorizeURLString
        ) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
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
    
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self) // при таком подходе не работает кнопка 
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
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: process code
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
