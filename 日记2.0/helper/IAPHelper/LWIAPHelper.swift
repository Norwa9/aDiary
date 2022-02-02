//
//  LWIAPHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/7.
//

import Foundation
import StoreKit

enum LWProductIdentifier:String,CaseIterable{
//    case monthly = "com.LuoWei.aDiary.monthly"
//    case quarterly = "com.LuoWei.aDiary.quarterly"
//    case yearly = "com.LuoWei.aDiary.yearly"
    case permanent = "com.LuoWei.aDiary.permanent"
}

typealias didReceiveRequestBlock = ([SKProduct])->Void
typealias completionBlock = ()->Void
class LWIAPHelper:NSObject{
    static let shared:LWIAPHelper = LWIAPHelper()
    var products = [SKProduct]()
    
    ///请求商品信息的SKProductsRequest类对象
    ///确保对productRequest实例保持一个强引用，因为系统可能在请求完成之前释放这个请求。
    fileprivate var productsRequest:SKProductsRequest!
    
    ///从apple connect获取到所有商品后的回调
    var fetchProductsCompletionBlock:didReceiveRequestBlock!
    
    /// 购买成功回到
    var purchaseCompletionBlock:completionBlock!
    
    ///成功恢复后的回调
    var restoreCompletionBlock:completionBlock!
    
    ///获取定义好的商品
    public func requestProducts() {
        let productIds = LWProductIdentifier.allCases.map { (p) -> String in
            return p.rawValue
        }
        let productIdsSet = Set(productIds)
        productsRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    ///使用
    public func initFreeTrial(){
        // 测试(初始化为未订阅)
        print("当前订阅版本：\(userDefaultManager.purchaseEdition)")
        // userDefaultManager.purchaseEdition = .notPurchased
        
        //  计算是否试用
        if let downloadDate = userDefaultManager.downloadDate{
            // 计算使用时间
            let freeTrialEndDate = downloadDate.addingTimeInterval(60 * 60 * 24) // 60 * 60 * 24
            let nowDate = Date()
            if  nowDate.compare(freeTrialEndDate) == .orderedAscending{
                // 仍处于试用、购买、未购买
                // 状态不变
                
            }else{
                if userDefaultManager.purchaseEdition == .freeTrial {
                    // 状态改变：试用0->未购买1
                    userDefaultManager.purchaseEdition = .notPurchased
                }
                
            }
        }else{
            // 记录下载时间
            userDefaultManager.downloadDate = Date()
        }
    }
}

//MARK: -业务
extension LWIAPHelper{
    ///购买
    public func buy(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() { // canMakePayments：用户的IAP可能受限，例如儿童内购受限
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            // show error
            self.generateErrorAC()
        }
    }
    
    ///恢复购买记录
    public func restore(){
        ///will restore non-consumables and auto-renewable subscriptions.
        ///for each restored transaction,StoreKit notifies the app’s transaction observer by calling paymentQueue(_:updatedTransactions:) with a transaction state of SKPaymentTransactionState.restored
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    ///订阅成功或恢复成功后，调用此方法给用户提供购买的服务
    ///特别注意：一定要在 finishTransaction(_:)方法之前执行。
    private func UnlockingPurchasedContent(){
        
    }
}

//MARK: -SKProductsRequestDelegate
extension LWIAPHelper:SKProductsRequestDelegate{
    /// 获取到可内购的项目
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("didReceive productsRequest")
        let responsProducts = response.products
        let invalidProductsIds = response.invalidProductIdentifiers//app store不能识别的商品id
        //主线回调，刷新UI
        DispatchQueue.main.async {
            self.fetchProductsCompletionBlock(responsProducts)
        }
        
        responsProducts.forEach { (product) in
            print("标题：\(product.localizedTitle)，价格：\(product.price)")
        }
    }
}

//MARK: -交易结果。SKPaymentTransactionObserver
extension LWIAPHelper: SKPaymentTransactionObserver {
    /*
     要点：
     當狀態為代表成功的 purchased & restored(待會說明)和代表失敗的 failed 時，記得要呼叫 finishTransaction 完成交易，
     否則 iOS 會以為交易還未完成，下次打開 App 時會再觸發 paymentQueue(_:updatedTransactions:)。
     例如，购买一首歌曲，下载完成时才调用finishTransaction，这是因为若下载过程中退出APP，下次打开时可以重新调用paymentQueue(_:updatedTransactions:)继续歌曲的下载。
     */
    ///接收交易结果
    ///需要在appDelegate中设置LWIAPHelper为SKPaymentQueue 的observer
    ///以便能够在App启动时继续用户没有完成的交易
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            print("updatedTransactions called ,id:\(transaction.payment.productIdentifier)")
            switch transaction.transactionState {
            case .purchased:
                transcationPurchased(transaction)
            case .failed:
                transcationFailed(transaction)
            case .restored:
                transcationRrestored(transaction)
            case .purchasing:
                transcationPurchasing(transaction)
            case.deferred:
                transcationDeferred(transaction)
            @unknown default:
                break
            }
        }
    }
    
    /// 交易成功的回调
    // TODO: 持久化交易
    fileprivate func transcationPurchased(_ transcation: SKPaymentTransaction) {
//        print("交易成功...")
//        // 持久化订单信息
//        if let receiptUrl = Bundle.main.appStoreReceiptURL {//获取收据地址
//
//            let receipt = NSData(contentsOf: receiptUrl)
//
//            let receiptStr = receipt?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 3)) {// 模拟上传收据到服务端
//
//                print("receiptStr:\(String(describing: receiptStr))")
//                print("applicationUsername:\(String(describing: transcation.payment.applicationUsername))")
//                // 收据发送到服务器
//                // 收据验证成功之后结束交易
//                SKPaymentQueue.default().finishTransaction(transcation)
//                // 删除保存的订单信息
//            }
//        }
        print("交易成功")
        DispatchQueue.main.async {
            self.purchaseCompletionBlock()
        }
        finishTranscation(transcation)
    }
    
    /// 交易失败的回调
    fileprivate func transcationFailed(_ transcation: SKPaymentTransaction) {
        print("交易失败...")
        //除非用户手动取消交易
        guard let error = transcation.error as? SKError else{return}
        
        if error.code != .paymentCancelled {
            // show error
            self.generateErrorAC()
            print("交易失败描述:\(error.localizedDescription)")
        }
        
        finishTranscation(transcation)
        DispatchQueue.main.async {
            indicatorViewManager.shared.stop()
        }
        
    }
    
    /// 恢复购买的回调
    fileprivate func transcationRrestored(_ transcation: SKPaymentTransaction) {
        print("已经购买该商品，恢复中...")
        
        DispatchQueue.main.async {
            self.restoreCompletionBlock()
        }
        finishTranscation(transcation)
    }
    
    /// 交易中的回调
    fileprivate func transcationPurchasing(_ transcation: SKPaymentTransaction) {
        //
        print("交易中...")
    }
    
    /// 交易延期的回调
    fileprivate func transcationDeferred(_ transcation: SKPaymentTransaction) {
        
        print("交易延期...")
    }
    
    /**
     在结束交易前，确保以下工作全部完成！
     1. Persist the purchase.
     2. Download associated content.
     3. Update your app’s UI so the user can access the product.
     */
    private func finishTranscation(_ transcation:SKPaymentTransaction){
        SKPaymentQueue.default().finishTransaction(transcation)//交易成功、恢复成功、交易失败。都需要调用结束
    }
    
    // MARK: 生成警告窗口
    public func generateErrorAC(){
        let ac = UIAlertController(title: "出现错误，请重试", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "返回", style: .cancel, handler: { (_) in
            
        }))
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }
    
    public func generatePurchasedAC(){
        let ac = UIAlertController(title: "您已经购买过了，无需恢复", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (_) in
            
        }))
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }

}


