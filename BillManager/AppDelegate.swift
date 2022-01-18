//
//  AppDelegate.swift
//  BillManager
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let center = UNUserNotificationCenter.current()
        let snoozeAction = UNNotificationAction(identifier: Bill.snoozeActionId, title: "Remind me in an hour", options: [])
        let markAsPaidAction = UNNotificationAction(identifier: Bill.markAsPaidId, title: "Mark as Paid", options: [.authenticationRequired])
        let categoryAction = UNNotificationCategory(identifier: Bill.notificationCategoryId, actions: [snoozeAction, markAsPaidAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories([categoryAction])
        center.delegate = self
        
        return true
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationId = response.notification.request.identifier
        var bill = Database.shared.getBill(forNotificationId: notificationId)
        switch response.actionIdentifier{
        case Bill.snoozeActionId:
            let snoozeDate = Date().addingTimeInterval(3600)
            print(snoozeDate)
            bill.addReminder(remindDate: snoozeDate) { bill in
                Database.shared.save()
            }
        
        case Bill.markAsPaidId:
            bill.paidDate = Date()
            Database.shared.save()
        print("mark as paid")
        default:
            return
        }
        
     completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound])
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
}

