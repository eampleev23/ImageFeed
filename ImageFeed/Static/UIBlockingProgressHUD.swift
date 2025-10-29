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
    private static var containerView: UIView? // Добавляем контейнер для прелоадера
    
    static func show() {
        
        dismiss()
        guard let window = getKeyWindow() else { return }
        
        let overlay = UIView(frame: window.bounds)
        
        let containerSize: CGFloat = 51
        let containerView = UIView(frame: CGRect(
            x: (window.bounds.width - containerSize) / 2,
            y: (window.bounds.height - containerSize) / 2,
            width: containerSize,
            height: containerSize
        ))
        containerView.backgroundColor = .ypWhite // Белый фон только для прелоадера
        containerView.layer.cornerRadius = 16 // Закругленные углы
        containerView.layer.masksToBounds = true
        
        // Создаем анимацию Lottie
        let animationView = LottieAnimationView(name: "loading_gray")
        animationView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        animationView.center = CGPoint(x: containerSize / 2, y: containerSize / 2)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        
        // Добавляем элементы в иерархию
        containerView.addSubview(animationView)
        overlay.addSubview(containerView)
        window.addSubview(overlay)
        
        // Сохраняем ссылки
        self.overlayView = overlay
        self.containerView = containerView
        self.animationView = animationView
        
        animationView.play()
        window.isUserInteractionEnabled = false
    }
    
    static func dismiss() {
        animationView?.stop()
        overlayView?.removeFromSuperview()
        overlayView = nil
        containerView = nil
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
