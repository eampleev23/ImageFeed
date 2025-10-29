// WebViewProgressController.swift
import UIKit
import WebKit

final class WebViewProgressController: NSObject {
    
    // MARK: - Constants
    private enum Constants {
        static let progressTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        static let trackTintColor = UIColor.clear
        static let height: CGFloat = 2
        static let fakeProgressStep: Float = 0.015
        static let fakeProgressSlowStep: Float = 0.005
        static let fakeProgressTarget: Float = 0.7
        static let fakeProgressInterval: TimeInterval = 0.1
        static let smoothProgressInterval: TimeInterval = 0.05
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Properties
    private let progressView: UIProgressView
    private weak var webView: WKWebView?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private var isObserving = false
    private var progressTimer: Timer?
    private var targetProgress: Float = 0.0
    private var isLoadCompleted = false
    private var fakeProgressTimer: Timer?
    private var fakeProgress: Float = 0.0
    
    var onProgressComplete: (() -> Void)?
    
    // MARK: - Init
    init(webView: WKWebView) {
        self.webView = webView
        self.progressView = UIProgressView()
        super.init()
        setupProgressView()
    }
    
    deinit {
        stopObserving()
    }
    
    // MARK: - KVO
    func startObserving() {
        
        guard !isObserving, let webView = webView else { return }
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new],
             changeHandler: { [weak self] webView, change in
                 guard let self else { return }
                 let newProgress = Float(webView.estimatedProgress)
                 self.updateProgressSmoothly(to: newProgress)
             }
        )
        isObserving = true
        startFakeProgress()
    }
    
    func stopObserving() {
        guard isObserving, webView != nil else { return }
        
        estimatedProgressObservation = nil
        isObserving = false
        invalidateTimers()
    }
    
    func getProgressView() -> UIProgressView {
        return progressView
    }
    
    // MARK: - Private Methods
    private func setupProgressView() {
        progressView.progressTintColor = Constants.progressTintColor
        progressView.trackTintColor = Constants.trackTintColor
        progressView.progress = 0.0
        progressView.alpha = 1.0
    }
    
    private func startFakeProgress() {
        
        guard webView != nil else { return }
        
        fakeProgressTimer?.invalidate()
        fakeProgress = 0.0
        progressView.setProgress(0.0, animated: false)
        
        
        
        fakeProgressTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.fakeProgressInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateFakeProgress()
        }
    }
    
    private func updateFakeProgress() {
        if self.fakeProgress < Constants.fakeProgressTarget {
            // Определяем шаг прогресса
            let step: Float = self.fakeProgress > 0.6 ?
            Constants.fakeProgressSlowStep :
            Constants.fakeProgressStep
            
            self.fakeProgress += step
            let currentProgress = max(self.progressView.progress, self.fakeProgress)
            self.progressView.setProgress(currentProgress, animated: true)
        } else {
            self.fakeProgressTimer?.invalidate()
            self.fakeProgressTimer = nil
        }
    }
    
    private func updateProgressSmoothly(to target: Float) {
        targetProgress = target
        fakeProgressTimer?.invalidate()
        fakeProgressTimer = nil
        
        if target >= 1.0 {
            progressTimer?.invalidate()
            progressTimer = nil
            progressView.setProgress(1.0, animated: true)
            
            isLoadCompleted = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.hideProgressView()
            }
            return
        }
        
        if progressView.alpha == 0.0 {
            progressView.alpha = 1.0
        }
        
        startSmoothProgressAnimation()
    }
    
    private func startSmoothProgressAnimation() {
        progressTimer?.invalidate()
        
        progressTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.smoothProgressInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateSmoothProgress()
        }
    }
    
    private func updateSmoothProgress() {
        let currentProgress = progressView.progress
        let difference = targetProgress - currentProgress
        
        if abs(difference) < 0.01 || targetProgress <= currentProgress {
            progressView.setProgress(targetProgress, animated: true)
        } else {
            let step = difference * 0.3
            let newProgress = currentProgress + step
            progressView.setProgress(newProgress, animated: true)
        }
        
        if currentProgress >= targetProgress {
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }
    
    private func hideProgressView() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.progressView.alpha = 0.0
        } completion: { [weak self] _ in
            self?.progressView.setProgress(0.0, animated: false)
            self?.onProgressComplete?()
        }
    }
    
    private func invalidateTimers() {
        progressTimer?.invalidate()
        progressTimer = nil
        fakeProgressTimer?.invalidate()
        fakeProgressTimer = nil
    }
}
