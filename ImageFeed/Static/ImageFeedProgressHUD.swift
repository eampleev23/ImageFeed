//
//  ImageFeedProgressHUD.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 30.10.2025.
//
//  ImageFeedProgressHUD.swift
//  ImageFeed

import UIKit
import Lottie

final class ImageFeedProgressHUD {
    
    private static var overlayView: UIView?
    private static var animationView: LottieAnimationView?
    
    static func show() {
        dismiss()
        guard let window = getKeyWindow() else { return }
        
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .clear // Прозрачный фон
        
        let animationView = LottieAnimationView(name: "loading_gray") // Используем ту же анимацию
        let animationSize: CGFloat = 24
        animationView.frame = CGRect(
            x: (window.bounds.width - animationSize) / 2,
            y: window.bounds.height - 120, // Прелоадер внизу экрана
            width: animationSize,
            height: animationSize
        )
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        
        overlay.addSubview(animationView)
        window.addSubview(overlay)
        
        self.overlayView = overlay
        self.animationView = animationView
        
        animationView.play()
    }
    
    static func dismiss() {
        animationView?.stop()
        overlayView?.removeFromSuperview()
        overlayView = nil
        animationView = nil
    }
    
    private static func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
