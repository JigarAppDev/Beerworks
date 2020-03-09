//
//  AppDelegate.swift
//  BeerElite
//
//  Created by Jigar on 13/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleSignIn
import UserNotifications
import Firebase
import FirebaseMessaging

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        //Google SignIn
        GIDSignIn.sharedInstance().clientID = "608224284679-n503ij8uvmt78a1ouh1027mf0l388v25.apps.googleusercontent.com"
        //"439066783972-6m2ctakfhd47nqruq2mr324kb87o6eof.apps.googleusercontent.com"
//        self.registerForPushNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    @objc func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    //MARK:- Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNS Device Token: \(token)")
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID FCM token: \(result.token)")
                //  fcmTokenGL = result.token
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
        if notification.request.content.body == "New messages" {
            if UserDefaults.standard.value(forKey: "chat_badge") != nil {
                var chatBadge = UserDefaults.standard.value(forKey: "chat_badge")as! Int
                chatBadge = chatBadge + 1
                UserDefaults.standard.setValue(chatBadge, forKeyPath: "chat_badge")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatBadgeNotification"),
                object: nil,
                userInfo: nil)
            }else {
                UserDefaults.standard.setValue(1, forKeyPath: "chat_badge")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatBadgeNotification"),
                object: nil,
                userInfo: nil)
            }
        } else {
            if Defaults.value(forKey: "badge_count") != nil {
                let oldBadge = Defaults.value(forKey: "badge_count") as! Int
                let newBadge = oldBadge + 1
                Defaults.setValue(newBadge, forKey: "badge_count")
                
//                NotificationCenter.default.post(name: .textWasDownloadedNotification,
//                                                object: nil,
//                                                userInfo: nil)
            }else {
                Defaults.setValue(1, forKey: "badge_count")
            }
        }
        print(notification.request.content.body)
        if notification.request.content.body == "New quote request" {
            //You have new quotes request - Provider added quotes
            //for USER
            NOTIFICATION_TYPE = "1"
            Defaults.setValue("1", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "Your Quotes Accepted!" {
            //Quotes accepted by User
            //for Provider
            NOTIFICATION_TYPE = "2"
            Defaults.setValue("2", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "Your Quotes Request Rejected!" {
            //Quotes rejected by User
            //for Provider
            NOTIFICATION_TYPE = "3"
            Defaults.setValue("3", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "Your Order Is Completed By Provider!" {
            //Order Completed by provider
            //for User
            NOTIFICATION_TYPE = "4"
            Defaults.setValue("4", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "Your Order Is Completed By Users!" {
            //Order completed by User
            //for Provider
            NOTIFICATION_TYPE = "5"
            Defaults.setValue("5", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "Your Have New Review!" {
            //New Review User to provider
            //for Provider
            NOTIFICATION_TYPE = "6"
            Defaults.setValue("6", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "Your Have New Review!" {
            //New Review Provider to user
            //for User
            NOTIFICATION_TYPE = "7"
            Defaults.setValue("7", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "New jobs" {
            //User add new job
            //for provider
            NOTIFICATION_TYPE = "8"
            Defaults.setValue("8", forKey: "notification")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else if notification.request.content.body == "New messages" {
            //New Chat Msg
            NOTIFICATION_TYPE = "10"
            Defaults.setValue("10", forKey: "notification")
            //NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
        } else {
            //New Chat Msg
            NOTIFICATION_TYPE = "10"
            Defaults.setValue("10", forKey: "notification")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        let userInfo = response.notification.request.content.userInfo
        let type = userInfo[AnyHashable("type")]! as! String
        NOTIFICATION_TYPE = type
        let state = UIApplication.shared.applicationState
        if state == .inactive || state == .background {
            switch type {
            case "1":
                //You have new quotes request - Provider added quotes
                //for USER
                Defaults.setValue("1", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "2":
                //Quotes accepted by User
                //for Provider
                Defaults.setValue("2", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "3":
                //Quotes rejected by User
                //for Provider
                Defaults.setValue("3", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "4":
                //Order Completed by provider
                //for User
                Defaults.setValue("4", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "5":
                //Order completed by User
                //for Provider
                Defaults.setValue("5", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "6":
                //New Review User to provider
                //for User
                Defaults.setValue("6", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "7":
                //New Review Provider to user
                //for User
                Defaults.setValue("7", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "8":
                //User add new job
                //for provider
                Defaults.setValue("8", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "10":
                //Chat Msg
                Defaults.setValue("10", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            default:
                print(Defaults)
                Defaults.setValue("10", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            }
        }
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error){
        print("Failed to register: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM TOKEN : \(fcmToken)")
        DEVICETOKEN = fcmToken
        Defaults.set(fcmToken, forKey: "device_token")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        NSLog("USER INFO PUSH: %@", userInfo)
        let type = userInfo[AnyHashable("type")]! as! String
        NOTIFICATION_TYPE = type
        let state = UIApplication.shared.applicationState
        if state == .inactive || state == .background {
            switch type {
            case "1":
                //You have new quotes request - Provider added quotes
                //for USER
                Defaults.setValue("1", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "2":
                //Quotes accepted by User
                //for Provider
                Defaults.setValue("2", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "3":
                //Quotes rejected by User
                //for Provider
                Defaults.setValue("3", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "4":
                //Order Completed by provider
                //for User
                Defaults.setValue("4", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "5":
                //Order completed by User
                //for Provider
                Defaults.setValue("5", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "6":
                //New Review User to provider
                //for User
                Defaults.setValue("6", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "7":
                //New Review Provider to user
                //for User
                Defaults.setValue("7", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "8":
                //User add new job
                //for provider
                Defaults.setValue("8", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            case "10":
                //Chat Msg
                Defaults.setValue("10", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            default:
                print(Defaults)
                Defaults.setValue("10", forKey: "notification")
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "moveTabBasedOnPushType"), object: nil)
            }
        }
    }
    
}

