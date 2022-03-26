//
//  LWPagesManager.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/26.
//

import Foundation

class LWPagesManager{
    static let shared = LWPagesManager()
    
    
    /// 创建页面，并在models中插入页面，并更新models的中所有日记的顺序信息
    /// - Parameters:
    ///   - mainPageDateCN: 子页面所属主页面的日期
    ///   - insertAt: 在第几个页面之后插入
    ///   - template: 是否使用了模板
    func insertPage(models:[diaryInfo],mainPageDateCN:String,insertAfter:Int,template:diaryInfo?) -> [diaryInfo]{
        print("插入页面坐标：\(insertAfter)")
        var newModels = models
        var newPage:diaryInfo
//        if newModels.first ==
        
        // 确定最大的pageNumber
        let currentMaxPageIndex = LWRealmManager.shared.queryMaxSubpagesSuffix(dateCN: mainPageDateCN)
        let pageSuffix = currentMaxPageIndex + 1
        
        if let template = template{
            // 1. 有模板，表示创建模板页面
            if let templatedNewPage = LWTemplateHelper.shared.createDiaryUsingTemplate(dateCN: mainPageDateCN, pageIndex: pageSuffix, template: template){
                newPage = templatedNewPage
            }else{
                // 1.1 模板创建失败，返回空日记
                newPage = LWRealmManager.shared.createPage(withDate: mainPageDateCN, pageNumber: pageSuffix)
            }
        }else{
            // 1.3 没有模板，表示创建空页面
            newPage = LWRealmManager.shared.createPage(withDate: mainPageDateCN, pageNumber: pageSuffix)
        }
        
        LWRealmManager.shared.update {
            // 2. 初始化赋予page index
            // ⚠️NOTE⚠️: 不能直接newPage.metaData.pageIndex赋值，赋值会没有效果
            let insertAt = insertAfter + 1
            newPage.metaData = pageMetaData(pageIndex: insertAt - 1)
            newModels.insert(newPage, at: insertAt)
            // 3. 更新插入页面以及后续的页面的page index 递增1
            for i in insertAt..<newModels.count{
                let oldPageIndex = newModels[i].metaData.pageIndex
                let metaData = pageMetaData(pageIndex: oldPageIndex + 1)
                
                newModels[i].metaData = metaData
                newModels[i].editedButNotUploaded = true
                DiaryStore.shared.addOrUpdate(newModels[i]) // diary的属性被修改了，需要同步给云端
                print("pageIndex += 1，上传:\(newModels[i].date),index:\(newModels[i].indexOfPage)")
            }
        }
        
        print("插入页面成功，当前子页面下标：")
        for diary in newModels{
            print("日期：\(diary.date),metaData.pageIndex：\(diary.metaData.pageIndex)")
        }
        
        return newModels
    }
    
    /// 删除页面（主页面不能删）
    /// - Parameter diaryToDelete: 需要删除的日记的model
    func deletePage(models:[diaryInfo],deleteIndex:Int)->[diaryInfo]{
        // 主页面不能删除
        guard models.count > 1,deleteIndex < models.count else{
            return models
        }
        let deleteDiary = models[deleteIndex]
        var newModels = models
        
        // 1. 删除当前日记
        newModels.remove(at: deleteIndex)
        DiaryStore.shared.delete(with: deleteDiary.id)
        
        // 2. 更新其之后所有的日记index 递减1
        LWRealmManager.shared.update {
            for i in deleteIndex..<newModels.count{
                let oldPageIndex = newModels[i].metaData.pageIndex
                let metaData = pageMetaData(pageIndex: oldPageIndex - 1)
                
                newModels[i].metaData = metaData
                newModels[i].editedButNotUploaded = true
                DiaryStore.shared.addOrUpdate(newModels[i]) // diary的属性被修改了，需要同步给云端
                print("pageIndex -= 1，上传:\(newModels[i].date),index:\(newModels[i].indexOfPage)")
            }
        }
        
        print("删除页面成功，当前子页面下标：")
        for diary in newModels{
            print("日期：\(diary.date),metaData.pageIndex：\(diary.metaData.pageIndex)")
        }
        
        
        return newModels
    }
}
