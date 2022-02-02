//
//  Error+CloudKit.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/4.
//

import Foundation
import UIKit
import os.log
import CloudKit

extension Error{
    /// Whether this error is a CloudKit server record changed error, representing a record conflict
    var isCloudKitConflict: Bool {
        let effectiveError = self as? CKError

        return effectiveError?.code == CKError.Code.serverRecordChanged
    }
    
    /// resolver是一个闭包，用于解决冲突，其返回的是无冲突的record。
    ///
    /// - Parameter : resolver: 一个闭包，接受两个参数分别为客户端上的record和服务器上的record。
    /// - Returns: 由闭包resolver返回的，没有冲突的record。
    func resolveConflict(with resolver:(CKRecord,CKRecord)->CKRecord?) ->CKRecord?{
        guard let effectiveError = self as? CKError else{
            os_log("resolveConflict called on an error that was not a CKError. The error was %{public}@",
                   log: .default,
                   type: .fault,
                   String(describing: self))
            return nil
        }
        
        guard effectiveError.code == .serverRecordChanged else {
            os_log("resolveConflict called on a CKError that was not a serverRecordChanged error. The error was %{public}@",
                   log: .default,
                   type: .fault,
                   String(describing: effectiveError))
            return nil
        }
        
        //获取客户端上的record
        guard let clientRecord = effectiveError.userInfo[CKRecordChangedErrorClientRecordKey] as? CKRecord else {
            os_log("Failed to obtain client record from serverRecordChanged error. The error was %{public}@",
                   log: .default,
                   type: .fault,
                   String(describing: effectiveError))
            return nil
        }
        
        //获取服务器上的record
        guard let serverRecord = effectiveError.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else{
            os_log("Failed to obtain server record from serverRecordChanged error. The error was %{public}@",
                   log: .default,
                   type: .fault,
                   String(describing: effectiveError))
            return nil
        }
        
        //调用resolver闭包来处理二者的冲突
        return resolver(clientRecord,serverRecord)
    }
    
    /// 如果解析出服务器返回的错误是一个可恢复错误，则重新执行操作。
    ///
    /// - Parameters:
    ///   - log: The logger to use for logging information about the error handling, uses the default one if not set
    ///   - block: The block that will execute the operation later if it can be retried
    /// - Returns: Whether or not it was possible to retry the operation
    @discardableResult func retryCloudKitOperationIfPossible(_ log:OSLog? = nil,with block: @escaping () -> Void) -> Bool {
        let effectiveLog:OSLog = log ?? .default
        
        //如果是可恢复的错误，错误的类型将会是CKError
        guard let effectiveError = self as? CKError else {return false}
        
        guard let retryDelay:Double = effectiveError.retryAfterSeconds else {
            os_log("此错误不是可恢复错误", log:effectiveLog,type:.error)
            DispatchQueue.main.async {
                //indicatorViewManager.shared.stop(withText: "⚠️无法连接iCloud，请检查网络状态⚠️\n\(effectiveError.localizedDescription)")
                // indicatorViewManager.shared.stop(withText: "\(effectiveError.localizedDescription)")
//                indicatorViewManager.shared.stop()
            }
            return false
        }
        
        os_log("此错误是可恢复错误. 将会在 %{public}f 秒后重试", log: effectiveLog, type: .error, retryDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            block()//在delay后执行，即执行该block时此函数已经执行完毕，所以是逃逸闭包。
        }
        
        return true
    }
}

