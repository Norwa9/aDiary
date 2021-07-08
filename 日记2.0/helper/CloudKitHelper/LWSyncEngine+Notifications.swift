//
//  LWSyncEngine+Notifications.swift
//  日记2.0
//
//  Created by yy on 2021/7/8.
//

import Foundation
import CloudKit
import os.log

extension LWSyncEngine {

    @discardableResult func processSubscriptionNotification(with userInfo: [AnyHashable : Any]) -> Bool {
        os_log("%{public}@", log: log, type: .debug, #function)

        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            os_log("Not a CKNotification", log: self.log, type: .error)
            return false
        }

        guard notification.subscriptionID == privateSubscriptionId else {
            os_log("Not our subscription ID", log: self.log, type: .debug)
            return false
        }

        os_log("Received remote CloudKit notification for user data", log: log, type: .debug)

        fetchRemoteChanges()

        return true
    }
}
