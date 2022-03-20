//
//  LWSoundHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit
import RealmSwift
import CloudKit

/// 全局工具类：管理音频的上传、下载
class LWSoundHelper{
    static let shared = LWSoundHelper()
    
    var syncEngine: LWSyncEngine?
    
    // MARK: - public
    /// 开始上传&删除队列
    public func startEngine(){
        if userDefaultManager.iCloudEnable == false{
            return
        }
        
        // 移除空uuid
        let nonEmptyUploadQ = userDefaultManager.audioUploadQueue.filter { uuid in
            return uuid != ""
        }
        let nonEmptyDeleteQ = userDefaultManager.audioDeleteQueue.filter { uuid in
            return uuid != ""
        }
        userDefaultManager.audioUploadQueue = nonEmptyUploadQ
        userDefaultManager.audioDeleteQueue = nonEmptyDeleteQ
        
        // 继续上传音频到云端(一次最多上传400，多出来的下次进入App上传)
        self.uploadToCloud(uuids: userDefaultManager.audioUploadQueue.suffix(399))
        
        // 继续删除云端音频
        self.deleteOnCloud(uuids: userDefaultManager.audioDeleteQueue)
        
        
        print("LWSoundHelper start: audioUploadQueue大小：\(userDefaultManager.audioUploadQueue.count),audioDeleteQueue大小：\(userDefaultManager.audioDeleteQueue.count)")
    }
    
    /// 添加音频（保存+添加到上传队列）
    /// 本地保存一张音频，并添加到上传队列
    public func addAudios(audios:[LWSound],needUpload:Bool = true){
        if audios.isEmpty{
            return
        }
        // 1.保存本地
        for audio in audios {
            self.addToRealm(audio: audio)
            if !userDefaultManager.audioUploadQueue.contains(audio.uuid){
                userDefaultManager.audioUploadQueue.append(audio.uuid)
            }
        }
        if needUpload{
            self.uploadToCloud(audios: audios) // 一次上传一张，只有反复上传失败的才会留在上传队列里
        }
    }
    
    /// 删除音频（删除+从队列移除）
    /// 从本地删除该音频，然后从上传队列移除，阻止上传
    public  func deleteSounds(uuidsToDel:[String]){
        if uuidsToDel.isEmpty{
            return
        }
        for uuid in uuidsToDel {
            if uuid == ""{
                continue
            }
            
            // 1.从上传队列移除，它不必再上传
            if let i = userDefaultManager.audioUploadQueue.firstIndex(of: uuid){
                userDefaultManager.audioUploadQueue.remove(at: i)
            }
            
            // 2.从本地Realm删除
            let predicate = NSPredicate(format: "uuid == %@", uuid)
            self.deleteFromRealm(predicate: predicate)
            
            // 3.添加到云端待删除队列
            if !userDefaultManager.audioDeleteQueue.contains(uuid){
                userDefaultManager.audioDeleteQueue.append(uuid) // 只有在接收到云端返回的ack后，才从删除queue移除该uuid
            }
        }
        
        // 4. 尝试云端删除照片
        self.deleteOnCloud(uuids: uuidsToDel)
        
        
    }
    
    /// 查找音频
    func loadAudio(uuid:String) -> Data?{
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        let res = self.query(predicate: predicate)
        if let audio = res.first, let data = audio.soundData{
            return data
        }
        print("读取音频失败,uuid:\(uuid)")
        
        return nil // 读取失败返回占位图
    }
    
    
    //MARK: - Private
    /// 查询
    private func query(predicate:NSPredicate)-> Results<LWSound>{
        let realm = LWRealmManager.shared.realm
        let res = realm.objects(LWSound.self).filter(predicate)
        return res
    }
    
    /// 添加
    private func addToRealm(audio:LWSound){
        let realm = LWRealmManager.shared.realm
        do{
            try realm.write(){
                //如果object已经添加到realm被realm所管理，这个object不能在write事务block之外修改！
                realm.add(audio,update: .modified)
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
            if let audio = res.first{
                records.append(audio.record)
            }
        }
        
        self.syncEngine?.upload(records)
    }
    
    /// 上传到iCloud[SIs]
    private func uploadToCloud(audios:[LWSound]){
        var records:[CKRecord] = []
        for audio in audios {
            records.append(audio.record)
        }
        
        self.syncEngine?.upload(records)
    }
    
    /// 从iCloud删除
    private func deleteOnCloud(uuids:[String]){
        self.syncEngine?.delete(uuids,recordType: .LWSound)
    }
    
    
    
    /// 上传成功后，更新本地Model的[已上传状态]
    func setUploaded(records: [CKRecord]){
        let soundDB = LWRealmManager.shared.localSoundDatabase
        for r in records{
            guard let model = soundDB.first(where: { $0.uuid == r.recordID.recordName }) else {
                continue
            }
            //*赋值ckData，表示该日记已经在云端有副本
            LWRealmManager.shared.update {
                model.uploaded = true
            }
            
            // 从待上传队列移除
            if let index = userDefaultManager.audioUploadQueue.firstIndex(of: model.uuid){
                userDefaultManager.audioUploadQueue.remove(at: index)
            }
            
        }
        print("[音频]云端上传成功，更新上传队列，此时audioUploadQueue剩余个数：\(userDefaultManager.audioUploadQueue.count)")
    }
    
    /// 云端删除成功后，清空audio的待删除队列
    func setDeleted(recordIDs: [CKRecord.ID]?){
        if let ids = recordIDs{
            for id in ids{
                // 接收到云端返回的ack后，从待上传queue移除该uuid
                if let index = userDefaultManager.audioDeleteQueue.firstIndex(of: id.recordName){
                    userDefaultManager.audioDeleteQueue.remove(at: index)
                }
            }
            print("[音频]云端删除成功，更新删除队列，此时audioDeleteQueue剩余个数：\(userDefaultManager.audioDeleteQueue.count)")
            
//            let allimgsCount = LWRealmManager.shared.localSoundDatabase.count
//            print("删除完成，此时音频数据库元素个数：\(allimgsCount)")
        }
    }
        
    
    func updateAfterSync(_ audios:[LWSound]){
        if audios.isEmpty{
            //云端没有更新
            return
        }
        //1.将云端变动保存到本地数据库
        audios.forEach { updatedAudio in
            self.addToRealm(audio: updatedAudio)
        }
    }
    
    
    func updateAfterDelete(_ deletedIDs:[String]){
        if deletedIDs.isEmpty{
            //云端通知没有删除事件
            return
        }
        
        //1.删除
        for uuid in deletedIDs{
            //删除本地数据库数据
            let predicate = NSPredicate(format: "uuid == %@", uuid)
            self.deleteFromRealm(predicate: predicate)
            
            //假设设备A通知设备B删除x，且设备B在离线时也删除了x，那么设备B就把x从自己的待删除列表中移除
            if let index = userDefaultManager.audioDeleteQueue.firstIndex(of: uuid){
                userDefaultManager.audioDeleteQueue.remove(at: index)
            }
        }
    }
    
    // MARK: 页面删除
    /// 删除一个页面时，需要手动地删除其内所有音频
    func clearAllSounds(for page:diaryInfo){
        let soundModels = page.lwSoundModels
        let uuids = soundModels.map({ m in
            return m.uuid
        })
        print("删除页面： \(page.date) ...内有\(uuids.count)个音频。")
        self.deleteSounds(uuidsToDel: uuids)
    }
    
    /// 删除一个页面时，需要手动地删除其内所有音频
    func clearAllSounds(for pageID:String){
        guard let page = LWRealmManager.shared.queryDiaryWithID(pageID) else{
            return
        }
        let soundModels = page.lwSoundModels
        let uuids = soundModels.map({ m in
            return m.uuid
        })
        print("删除页面： \(page.date) ...内有\(uuids.count)个音频。")
        self.deleteSounds(uuidsToDel: uuids)
    }
    
    
}
