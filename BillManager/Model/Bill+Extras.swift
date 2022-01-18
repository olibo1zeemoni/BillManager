//
//  Bill+Extras.swift
//  BillManager
//

import Foundation
import UserNotifications


extension Bill {
   
    
    static let notificationCategoryId = "AlarmNotification"
    static let snoozeActionId = "snooze"
    static let markAsPaidId = "paid"
    var hasReminder: Bool {
        return (remindDate != nil)
    }
    
    var isPaid: Bool {
        return (paidDate != nil)
    }
    
    var formattedDueDate: String {
        let dateString: String
        
        if let dueDate = self.dueDate {
            dateString = dueDate.formatted(date: .numeric, time: .omitted)
        } else {
            dateString = ""
        }
        
        return dateString
    }
    
     func authorizeIfNeeded(completion: @escaping (Bool) -> ()){
         let notificationCenter = UNUserNotificationCenter.current()
         notificationCenter.getNotificationSettings { settings in
             switch settings.authorizationStatus{
                 
             case .notDetermined:
                 notificationCenter.requestAuthorization(options: [.alert, .sound, ]) { (granted, _) in
                     completion(granted)
                 }
             case .authorized:
                 completion(true)
             case .provisional, .denied, .ephemeral:
                 completion(false)
             @unknown default:
                 completion(false)
             }
         }
         
     }
        
    
    
   /* private*/  mutating func removeReminder(){
      if let id = notificationId {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
      }
      notificationId = nil
      remindDate = nil
    }
    
    mutating func addReminder(remindDate: Date, completion: @escaping (Bill)  -> ()) {
         var updatedBill = self
        removeReminder()
        authorizeIfNeeded { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                    completion(updatedBill)
            }
                return
            }
            let content = UNMutableNotificationContent()
            content.body = "$\(updatedBill.amount!) due to \(updatedBill.payee!) on \(updatedBill.dueDate!.formatted())"
            content.title = "Bill Reminder"
            content.badge = 1
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = Bill.notificationCategoryId
           let newNotificationId = UUID().uuidString
            updatedBill.notificationId = newNotificationId
            let triggerDateComponent = Calendar.current.dateComponents([.minute,.hour,.day,.month,.year], from: remindDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponent, repeats: false)
            let request = UNNotificationRequest(identifier: updatedBill.notificationId!, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error)
                        completion(updatedBill)
                    } else {
                        updatedBill.remindDate = remindDate
                        updatedBill.notificationId = newNotificationId
                        completion(updatedBill)
                    }
                }
            
            
        }
    }
  }
}
