//
//  MessageUIPresenter.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-11.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit
import MessageUI

class MessageUIPresenter: NSObject, Trackable {
    
    weak var presenter: UIViewController?
    
    /** Allows the user to share a wallet address and QR code image using the iOS system share action sheet. */
    func presentShareSheet(text: String, image: UIImage) {
        let shareItems = [text, image] as [Any]
        let shareVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        shareVC.excludedActivityTypes = shareAddressExclusions
        present(shareVC)
    }
        
    func presentFeedbackCompose() {
        guard MFMailComposeViewController.canSendMail() else { showEmailUnavailableAlert(); return }
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        let emailView = MFMailComposeViewController()
        emailView.setToRecipients([C.feedbackEmail])
        emailView.mailComposeDelegate = self
        present(emailView)
    }
    
    func presentMailCompose(emailAddress: String) {
        guard MFMailComposeViewController.canSendMail() else { showEmailUnavailableAlert(); return }
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        let emailView = MFMailComposeViewController()
        emailView.setToRecipients([emailAddress.replacingOccurrences(of: "%40", with: "@")])
        emailView.mailComposeDelegate = self
        saveEvent("receive.presentMailCompose")
        present(emailView)
    }
    
    // MARK: - Private
    
    // Filters out the sharing options that don't make sense for sharing a wallet
    // address and QR code. `saveToCameraRoll` is excluded because it crashes
    // without adding `NSPhotoLibraryAddUsageDescription` to the plist.
    private var shareAddressExclusions: [UIActivityType] {
        return [.airDrop, .openInIBooks, .addToReadingList, .saveToCameraRoll, .assignToContact]
    }
    
    private var originalTitleTextAttributes: [NSAttributedStringKey: Any]?
    
    private func present(_ viewController: UIViewController) {
        presenter?.view.isFrameChangeBlocked = true
        presenter?.present(viewController, animated: true, completion: {})
    }
    
    fileprivate func dismiss(_ viewController: UIViewController) {
        UINavigationBar.appearance().titleTextAttributes = originalTitleTextAttributes
        viewController.dismiss(animated: true, completion: {
            self.presenter?.view.isFrameChangeBlocked = false
        })
    }
    
    private func showEmailUnavailableAlert() {
        saveEvent("receive.emailUnavailable")
        let alert = UIAlertController(title: S.ErrorMessages.emailUnavailableTitle, message: S.ErrorMessages.emailUnavailableMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.ok, style: .default, handler: nil))
        presenter?.present(alert, animated: true, completion: nil)
    }
    
    private func showMessageUnavailableAlert() {
        saveEvent("receive.messagingUnavailable")
        let alert = UIAlertController(title: S.ErrorMessages.messagingUnavailableTitle, message: S.ErrorMessages.messagingUnavailableMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.ok, style: .default, handler: nil))
        presenter?.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: S.Alert.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.ok, style: .default, handler: nil))
        presenter?.present(alert, animated: true, completion: nil)
    }
}

extension MessageUIPresenter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(controller)
    }
}

extension MessageUIPresenter: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(controller)
    }
}
