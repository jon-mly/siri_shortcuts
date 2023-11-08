//
//  VoiceShortcutViewControllerDelegate.swift
//  siri_shortcuts
//
//  Created by Sarbagya Dhaubanjar on 18/10/2022.
//

import IntentsUI

@available(iOS 12.0, *)
class VoiceShortcutViewControllerDelegate: NSObject, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    
    let completion: (CreateShortcutResult) -> Void
    let onEditingComplete: (UUID?) -> Void
    
    init(completion: @escaping (CreateShortcutResult) -> Void, onEditingComplete: @escaping (UUID?) -> Void) {
        self.completion = completion
        self.onEditingComplete = onEditingComplete
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if error == nil {
            dismissModal(controller: controller, status: .added, shortcut: voiceShortcut)
        } else {
            dismissModal(controller: controller, status: .cancelled, errorMessage: error?.localizedDescription)
        }
    }
    
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        dismissModal(controller: controller, status: .cancelled)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        if error == nil {
            dismissModal(controller: controller, status: .updated, shortcut: voiceShortcut)
        } else {
            dismissModal(controller: controller, status: .cancelled, errorMessage: error?.localizedDescription)
        }
        self.onEditingComplete(nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        dismissModal(controller: controller, status: .deleted)
        self.onEditingComplete(deletedVoiceShortcutIdentifier)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        dismissModal(controller: controller, status: .cancelled)
        self.onEditingComplete(nil)
    }
    
    func dismissModal<C: UIViewController>(controller: C, status: CreateShortcutStatus, shortcut: INVoiceShortcut? = nil, errorMessage: String? = nil) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
            
            self.completion(CreateShortcutResult(status: status, phrase: shortcut?.invocationPhrase, errorMessage: errorMessage))
        }
    }
}

