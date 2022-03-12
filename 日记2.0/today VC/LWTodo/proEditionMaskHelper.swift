//
//  proEditionMaskHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/1.
//

import Foundation
import UIKit


class proEditionMaskHelper{
    static let shared = proEditionMaskHelper()
    
    typealias callback = ()->Void
    /// 检查是否未购买，如果是，则提醒开通Pro
    public func checkPurchaseAndPrompt(
        completion:@escaping callback
    ) -> Bool{
        let edition = userDefaultManager.purchaseEdition
        if edition == .notPurchased{
            // 未购买
            presentAC(completion)
            return false
        }else{
            // 试用或者购买
            return true
        }
    }
    
    private func presentAC(_ completion:@escaping callback){
        let ac = UIAlertController(title: "✨设置待办提醒✨", message: "请解锁完整版", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            completion()
        }))
        ac.addAction(UIAlertAction(title: "🔓解锁", style: .default, handler: { (_) in
            completion()
            let iapVC = IAPViewController()
            UIApplication.getTopViewController()?.present(iapVC, animated: true, completion: nil)
        }))
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }
}
