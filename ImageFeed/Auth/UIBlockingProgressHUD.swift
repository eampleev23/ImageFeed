//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 22.10.2025.
//

import UIKit
import Lottie

final class UIBlockingProgressHUD {
    
    private static var overlayView: UIView?
    private static var animationView: LottieAnimationView?
    
    static func show() {
        guard let window = getKeyWindow() else { return }
        
        // Создаем overlay
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Создаем анимацию Lottie
        let animationView = LottieAnimationView(name: "preloader")
        animationView.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        animationView.center = overlay.center
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        
        overlay.addSubview(animationView)
        window.addSubview(overlay)
        
        self.overlayView = overlay
        self.animationView = animationView
        
        animationView.play()
        window.isUserInteractionEnabled = false
    }
    
    static func dismiss() {
        animationView?.stop()
        overlayView?.removeFromSuperview()
        overlayView = nil
        animationView = nil
        
        getKeyWindow()?.isUserInteractionEnabled = true
    }
    
    private static func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
