//
//  imageTool.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/16.
//

import Foundation
import UIKit
import RealmSwift
import CloudKit

/// 全局工具类：管理图片的上传、下载
class ImageTool{
    static let shared = ImageTool()
    
    var syncEngine: LWSyncEngine?
    
    // MARK: - public
    /// 开始上传&删除队列
    public func startEngine(){
        if userDefaultManager.iCloudEnable == false{
            return
        }
        
        // 移除空uuid
        let nonEmptyUploadQ = userDefaultManager.imageUploadQueue.filter { uuid in
            return uuid != ""
        }
        userDefaultManager.imageUploadQueue = nonEmptyUploadQ
        let nonEmptyDeleteQ = userDefaultManager.imageDeleteQueue.filter { uuid in
            return uuid != ""
        }
        userDefaultManager.imageUploadQueue = nonEmptyUploadQ
        userDefaultManager.imageDeleteQueue = nonEmptyDeleteQ
        
        // 继续上传图片到云端(一次最多上传400，多出来的下次进入App上传)
        self.uploadToCloud(uuids: userDefaultManager.imageUploadQueue.suffix(399))
        
        // 继续删除云端图片
        self.deleteOnCloud(uuids: userDefaultManager.imageDeleteQueue)
        
        
        print("imageTool start: imageUploadQueue大小：\(userDefaultManager.imageUploadQueue.count),imageDeleteQueue大小：\(userDefaultManager.imageDeleteQueue.count)")
    }
    
    /// 添加图片（保存+添加到上传队列）
    /// 本地保存一张图片，并添加到上传队列
    public func addImages(SIs:[scalableImage],needUpload:Bool = true){
        if SIs.isEmpty{
            return
        }
        // 1.保存本地
        for si in SIs {
            self.addToRealm(si: si)
            if !userDefaultManager.imageUploadQueue.contains(si.uuid){
                userDefaultManager.imageUploadQueue.append(si.uuid)
            }
        }
        if needUpload{
            self.uploadToCloud(SIs: SIs) // 一次上传一张，只有反复上传失败的才会留在上传队列里
        }
    }
    
    /// 删除图片（删除+从队列移除）
    /// 从本地删除该图片，然后从上传队列移除，阻止上传
    public  func deleteImages(uuidsToDel:[String]){
        if uuidsToDel.isEmpty{
            return
        }
        for uuid in uuidsToDel {
            if uuid == ""{
                continue
            }
            
            // 1.从上传队列移除，它不必再上传
            if let i = userDefaultManager.imageUploadQueue.firstIndex(of: uuid){
                userDefaultManager.imageUploadQueue.remove(at: i)
            }
            
            // 2.从本地Realm删除
            let predicate = NSPredicate(format: "uuid == %@", uuid)
            self.deleteFromRealm(predicate: predicate)
            
            // 3.添加到云端待删除队列
            if !userDefaultManager.imageDeleteQueue.contains(uuid){
                userDefaultManager.imageDeleteQueue.append(uuid) // 只有在接收到云端返回的ack后，才从删除queue移除该uuid
            }
        }
        
        // 4. 尝试云端删除照片
        self.deleteOnCloud(uuids: uuidsToDel)
        
        
    }
    
    /// 查找图片
    func loadImage(uuid:String) -> UIImage?{
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        let res = self.query(predicate: predicate)
        if let si = res.first, let data = si.data{
            let image = UIImage(data: data)
            return image
        }
        print("读取图片失败,uuid:\(uuid)")
        
        return nil // 读取失败返回占位图
    }    
    
    
    //MARK: - Private
    /// 查询
    private func query(predicate:NSPredicate)-> Results<scalableImage>{
        let realm = LWRealmManager.shared.realm
        let res = realm.objects(scalableImage.self).filter(predicate)
        return res
    }
    
    /// 添加
    private func addToRealm(si:scalableImage){
        let realm = LWRealmManager.shared.realm
        do{
            try realm.write(){
                //如果object已经添加到realm被realm所管理，这个object不能在write事务block之外修改！
                realm.add(si,update: .modified)
            }
        }catch let error{
            print("[新增]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    
    /// 删除
    private func deleteFromRealm(predicate:NSPredicate){
        let realm = LWRealmManager.shared.realm
        let res = self.query(predicate: predicate)
        do{
            try realm.write(){
                realm.delete(res)
            }
        }catch let error{
            print("[述语批量删除]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    
    
    
    //MARK: -iCloud
    /// 上传到iCloud[uuids]
    private func uploadToCloud(uuids:[String]){
        if userDefaultManager.iCloudEnable == false{
            return
        }
        var records:[CKRecord] = []
        for uuid in uuids {
            let predicate = NSPredicate(format: "uuid == %@", uuid)
            let res = self.query(predicate: predicate)
            if let si = res.first{
                records.append(si.record)
            }
        }
        
        self.syncEngine?.upload(records)
    }
    
    /// 上传到iCloud[SIs]
    private func uploadToCloud(SIs:[scalableImage]){
        var records:[CKRecord] = []
        for si in SIs {
            records.append(si.record)
        }
        
        self.syncEngine?.upload(records)
    }
    
    /// 从iCloud删除
    private func deleteOnCloud(uuids:[String]){
        self.syncEngine?.delete(uuids,recordType: .scalableImage)
    }
    
    
    
    /// 上传成功后，更新本地Model的[已上传状态]
    func setUploaded(records: [CKRecord]){
        let imageDB = LWRealmManager.shared.localImageDatabase
        for r in records{
            guard let model = imageDB.first(where: { $0.uuid == r.recordID.recordName }) else {
                continue
            }
            //*赋值ckData，表示该日记已经在云端有副本
            LWRealmManager.shared.update {
                model.uploaded = true
            }
            
            // 从待上传队列移除
            if let index = userDefaultManager.imageUploadQueue.firstIndex(of: model.uuid){
                userDefaultManager.imageUploadQueue.remove(at: index)
            }
            
        }
        print("[图片]云端上传成功，更新上传队列，此时imageUploadQueue剩余个数：\(userDefaultManager.imageUploadQueue.count)")
    }
    
    /// 云端删除成功后，清空image的待删除队列
    func setDeleted(recordIDs: [CKRecord.ID]?){
        if let ids = recordIDs{
            for id in ids{
                // 接收到云端返回的ack后，从待上传queue移除该uuid
                if let index = userDefaultManager.imageDeleteQueue.firstIndex(of: id.recordName){
                    userDefaultManager.imageDeleteQueue.remove(at: index)
                }
            }
            print("[图片]云端删除成功，更新删除队列，此时imageDeleteQueue剩余个数：\(userDefaultManager.imageDeleteQueue.count)")
            
//            let allimgsCount = LWRealmManager.shared.localImageDatabase.count
//            print("删除完成，此时图片数据库元素个数：\(allimgsCount)")
        }
    }
        
    
    func updateAfterSync(_ images:[scalableImage]){
        if images.isEmpty{
            //云端没有更新
            indicatorViewManager.shared.stop()
            return
        }
        //1.将云端变动保存到本地数据库
        images.forEach { updatedImage in
            self.addToRealm(si: updatedImage)
        }
        DispatchQueue.main.async {
            //2.更新UI
            indicatorViewManager.shared.stop()
//            UIApplication.getMonthVC().reloadMonthVC()
//            UIApplication.getTodayVC()?.updateUI()
        }
    }
    
    
    func updateAfterDelete(_ deletedIDs:[String]){
        if deletedIDs.isEmpty{
            //云端通知没有删除事件
            indicatorViewManager.shared.stop()
            return
        }
        
        //1.删除
        for uuid in deletedIDs{
            //删除本地数据库数据
            let predicate = NSPredicate(format: "uuid == %@", uuid)
            self.deleteFromRealm(predicate: predicate)
            
            //假设设备A通知设备B删除x，且设备B在离线时也删除了x，那么设备B就把x从自己的待删除列表中移除
            if let index = userDefaultManager.imageDeleteQueue.firstIndex(of: uuid){
                userDefaultManager.imageDeleteQueue.remove(at: index)
            }
        }
        
        //2.更新UI
        DispatchQueue.main.async {
            indicatorViewManager.shared.stop()
            UIApplication.getMonthVC()?.reloadMonthVC()
            
        }
    }
    
    
}
