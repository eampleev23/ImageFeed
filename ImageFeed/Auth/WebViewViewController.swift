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
    
    private let progressView: UIProgressView = {
        let uiProgressView = UIProgressView()
        return uiProgressView
    }()
    
    // MARK: - Constants
    private enum NavConstants {
        static let backButtonLeftMargin: CGFloat = -16 // Сдвиг левее
        static let backButtonImageName = "nav_back_button"
    }
    
    // MARK: - Progress View Constants
    private enum ProgressConstants {
        static let progressTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) // #1A1B22
        static let trackTintColor = UIColor.clear
        static let height: CGFloat = 2
    }
    
    // Таймер для плавной анимации прогресса
    private var progressTimer: Timer?
    private var targetProgress: Float = 0.0
    private var isLoadCompleted = false
    
    // Добавили наблюдателя
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    // Планируем удаление наблюдателя
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // Добавляем обработчик обновлений
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            let newProgress = Float(webView.estimatedProgress)
            updateProgressSmoothly(to: newProgress)
        } else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
    }
    
    private func updateProgressSmoothly(to target: Float) {
        targetProgress = target
        
        // Если прогресс завершен
        if target >= 1.0 {
            progressTimer?.invalidate()
            progressTimer = nil
            progressView.setProgress(1.0, animated: true)
            
            // Помечаем что загрузка завершена
            isLoadCompleted = true
            
            // Скрываем прогресс-бар с задержкой и ПОСЛЕ этого показываем веб-вью
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIView.animate(withDuration: 0.3) {
                    self.progressView.alpha = 0.0
                } completion: { _ in
                    self.progressView.setProgress(0.0, animated: false)
                    // Теперь показываем веб-вью
                    self.showWebView()
                }
            }
            return
        }
        
        // Показываем прогресс-бар если он скрыт
        if progressView.alpha == 0.0 {
            progressView.setProgress(0.0, animated: false)
            UIView.animate(withDuration: 0.3) {
                self.progressView.alpha = 1.0
            }
        }
        
        // Запускаем плавное обновление прогресса
        startSmoothProgressAnimation()
    }
    
    private func startSmoothProgressAnimation() {
        progressTimer?.invalidate()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentProgress = self.progressView.progress
            let difference = self.targetProgress - currentProgress
            
            // Если разница небольшая, обновляем сразу
            if abs(difference) < 0.01 || self.targetProgress <= currentProgress {
                self.progressView.setProgress(self.targetProgress, animated: true)
            } else {
                // Плавно увеличиваем прогресс
                let step = difference * 0.3 // Коэффициент плавности
                let newProgress = currentProgress + step
                self.progressView.setProgress(newProgress, animated: true)
            }
            
            // Останавливаем таймер если достигли цели
            if currentProgress >= self.targetProgress {
                self.progressTimer?.invalidate()
                self.progressTimer = nil
            }
        }
    }
    
    private func showWebView() {
        // Показываем веб-вью с анимацией
        UIView.animate(withDuration: 0.3) {
            self.webView.alpha = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupUI()
        setupNavigationBar()
        setupProgressView()
        setupWebView()
        loadAuthView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        // Сначала добавляем все subviews
        view.addSubview(progressView)
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
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.alpha = 0.0 // Начинаем с прозрачным веб-вью
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка внешнего вида
        progressView.progressTintColor = ProgressConstants.progressTintColor
        progressView.trackTintColor = ProgressConstants.trackTintColor
        progressView.progress = 0.0 // Начальное значение 0
        progressView.alpha = 1.0 // Начинаем видимым
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: ProgressConstants.height)
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
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            // Если загрузка еще не завершена, ждем ее завершения
            if !isLoadCompleted {
                // Откладываем обработку кода до полной загрузки
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                }
            } else {
                delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
