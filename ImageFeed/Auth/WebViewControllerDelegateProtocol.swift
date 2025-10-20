//
//  WebViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
