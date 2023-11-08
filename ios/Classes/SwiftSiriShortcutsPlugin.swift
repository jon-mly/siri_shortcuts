//
//  SwiftSiriShortcutsPLugin.swift
//  siri_shortcuts
//
//  Created by Sarbagya Dhaubanjar on 17/10/2022.
//

import CoreSpotlight
import Flutter
import IntentsUI
import UIKit

extension FlutterError: Error {}

@available(iOS 12.0, *)
public class SwiftSiriShortcutsPlugin: NSObject, FlutterPlugin, SiriShortcutsApi {

    var voiceShortcutViewControllerDelegate: VoiceShortcutViewControllerDelegate?
    let flutterApi: SiriShortcutsFlutterApi
    let bundleId: String?
    let activityTypePrefix: String
    let shortcutNotificationName: Notification.Name
    
    init(flutterApi: SiriShortcutsFlutterApi) {
        self.flutterApi = flutterApi
        bundleId = Bundle.main.bundleIdentifier
        activityTypePrefix = "\(bundleId ?? "")."
        shortcutNotificationName = Notification.Name("\(activityTypePrefix)siri_shortcuts")
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        postNotification(userActivity: userActivity)
        return true
    }
    
    func postNotification(userActivity: NSUserActivity) {
        if userActivity.activityType.hasPrefix(activityTypePrefix) {
            flutterApi.onShortcutTriggered(detail: ShortcutDetail(activityType: userActivity.activityType, userInfo: userActivity.userInfo as? [String: Any] ?? [:])) { _ in
                return;
            }
        }
    }
    
    func createShortcut(options: ShortcutOptions, completion: @escaping (Result<CreateShortcutResult, Error>) -> Void) {
        let activity = NSUserActivity(activityType: "\(activityTypePrefix)\(options.activityType)")
        
        activity.title = options.title
        activity.suggestedInvocationPhrase = options.suggestedInvocationPhrase
        if options.userInfo != nil {
            activity.userInfo = options.userInfo! as [AnyHashable : Any]
        }
        
        let eligibility = options.eligibility
        activity.isEligibleForSearch = eligibility?.search ?? true
        activity.isEligibleForPrediction = eligibility?.prediction ?? true
        activity.isEligibleForHandoff = eligibility?.handOff ?? false
        activity.isEligibleForPublicIndexing = eligibility?.publicIndexing ??  false
        
        if options.requiredUserInfoKeys != nil {
            activity.requiredUserInfoKeys = Set<String>(options.requiredUserInfoKeys!.map({$0 ?? ""}))
        }
        activity.needsSave = options.needsSave ?? false
        
        if options.webpageURL != nil {
            activity.webpageURL = URL(string: options.webpageURL!)
            if options.referrerURL != nil {
                activity.referrerURL = URL(string: options.referrerURL!)
            }
        }
        if options.expirationDate != nil {
            activity.expirationDate = Date.init(timeIntervalSince1970: Double(options.expirationDate!))
        }
        if options.keywords != nil {
            activity.keywords = Set<String>(options.keywords!.map({$0 ?? ""}))
        }
        activity.persistentIdentifier = options.persistentIdentifier
        
        let attributes = CSSearchableItemAttributeSet(itemContentType: options.contentType ?? "text/plain")
        attributes.contentDescription = options.description
        activity.contentAttributeSet = attributes
        
        let shortcut = INShortcut(userActivity: activity)
        
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { voiceShortcuts,error in
            if voiceShortcuts == nil {
                completion(.success(CreateShortcutResult(status: .cancelled,errorMessage: "Failed fetching voice shortcuts: \(error.debugDescription)")))
            } else {
                let voiceShortcut = voiceShortcuts!.first { vs in
                    return vs.shortcut.userActivity?.activityType == activity.activityType
                }
                
                DispatchQueue.main.async {
                    self.voiceShortcutViewControllerDelegate = VoiceShortcutViewControllerDelegate(completion: completion, onEditingComplete: { deletedShortcutIdentifier in
                        
                    })
                    
                    var viewController: UIViewController
                    
                    if voiceShortcut == nil {
                        let addViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                        addViewController.delegate = self.voiceShortcutViewControllerDelegate
                        
                        viewController = addViewController
                    } else {
                        let editViewController = INUIEditVoiceShortcutViewController(voiceShortcut: voiceShortcut!)
                        editViewController.delegate = self.voiceShortcutViewControllerDelegate
                        
                        viewController = editViewController
                    }
                    
                    viewController.modalPresentationStyle = .formSheet
                    
                    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                    rootViewController?.present(viewController, animated: true)
                }
            }
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let plugin = SwiftSiriShortcutsPlugin(flutterApi: SiriShortcutsFlutterApi(binaryMessenger: messenger))
        
        SiriShortcutsApiSetup.setUp(binaryMessenger: messenger, api: plugin)
        registrar.addApplicationDelegate(plugin)
    }
}

