// WebViewViewController.swift
@preconcurrency import WebKit

final class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Constants
    private enum  WVVCConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        static let backButtonLeftMargin: CGFloat = -16
        static let backButtonImageName = "nav_back_button"
    }
    
    // MARK: - Properties
    private let webView = WKWebView()
    private var progressController: WebViewProgressController?
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupProgressController()
        setupUI()
        setupNavigationBar()
        setupWebView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadAuthView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressController?.startObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressController?.stopObserving()
    }
    
    // MARK: - Setup
    private func setupProgressController() {
        progressController = WebViewProgressController(webView: webView)
        progressController?.onProgressComplete = { [weak self] in
            self?.showWebView()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        // Добавляем progressView если контроллер создан
        if let progressView = progressController?.getProgressView() {
            view.addSubview(progressView)
        }
        
        view.addSubview(webView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        guard let progressView = progressController?.getProgressView() else { return }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: WVVCConstants.backButtonImageName),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        backButton.imageInsets = UIEdgeInsets(
            top: 0,
            left: WVVCConstants.backButtonLeftMargin,
            bottom: 0,
            right: 0
        )
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = YPColors.black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupWebView() {
        webView.alpha = 0.0
    }
    
    private func showWebView() {
        UIView.animate(withDuration: 0.3) {
            self.webView.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Auth
    private func loadAuthView() {
        guard var urlComponents = URLComponents(
            string: WVVCConstants.unsplashAuthorizeURLString
        ) else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AppConstants.accessKey),
            URLQueryItem(name: "redirect_uri", value: AppConstants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AppConstants.accessScope),
        ]
        
        guard let url = urlComponents.url else { return }
        
        webView.load(URLRequest(url: url))
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
        }
        return nil
    }
    
    // MARK: - WKNavigationDelegate
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
