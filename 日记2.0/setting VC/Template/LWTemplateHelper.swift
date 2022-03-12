//
//  LWTemplateHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import Foundation

class LWTemplateHelper{
    static let shared = LWTemplateHelper()
    let TemplateNamePrefix = "template-"
    /// 查询模板
    /// 如果不提供templateName则表示查询所有模板
    func getTemplateFor(templateRawName:String?) -> [diaryInfo]{
        //TODO: 模板名称不能超过主键最长字符数
        if let templateRawName = templateRawName {
            // 返回查询模板
            let queryName = TemplateNamePrefix + templateRawName
            if let template = LWRealmManager.shared.queryFor(dateCN: queryName).first{
                return [template]
            }
        }else{
            // 返回所有模板
            let predicate = NSPredicate(format: "date BEGINSWITH %@", TemplateNamePrefix)
            let templates = LWRealmManager.shared.query(predicate: predicate)
            return Array(templates)
        }
        return []
    }
    
    /// 创建
    func createTemplate(name:String) -> diaryInfo{
        let templateName = TemplateNamePrefix + name
        let template = diaryInfo(dateString: templateName)
        
        // 上传
        LWRealmManager.shared.add(template)
        DiaryStore.shared.addOrUpdate(template)
        
        return template
    }
    
    /// 修改名称
    func modifyTempalteName(oldTemplateRawName:String,newTemplateRawName:String){
        if let _ = getTemplateFor(templateRawName: newTemplateRawName).first{
            // 新的模板已经存在
            return
        }
        // 由于主键不能修改
        if let oldTemplate = getTemplateFor(templateRawName: oldTemplateRawName).first{
            // 1. 将旧模板的以新的名称重新创建，从而达到重命名
            let _ = createDiaryUsingTemplate(dateCN: TemplateNamePrefix+newTemplateRawName, pageIndex: 0, template: oldTemplate)
            // 2. 删除
            deleteTemplate(templateRawName: oldTemplateRawName)
        }
        
    }
    
    /// 删除
    func deleteTemplate(templateRawName:String){
        if let template = getTemplateFor(templateRawName: templateRawName).first{
            DiaryStore.shared.delete(with: template.id)
        }
    }
    
    
    /// 使用模板（读取模板）
    /// pageIndex=0时表示创建主日记
    /// pageIndex>0时表示在日记内创建新的页
    func createDiaryUsingTemplate(dateCN:String,pageIndex:Int,template:diaryInfo) -> diaryInfo?{
        // 拷贝
        var newDiary:diaryInfo
        if pageIndex == 0{ // 创建主页面
            newDiary = diaryInfo(dateString: dateCN)
            
        }else{ // 创建子页面
            let subPageDateCN = dateCN + "-" + "\(pageIndex)"
            newDiary = diaryInfo(dateString: subPageDateCN)
        }
        newDiary.modTime = Date()
        newDiary.content = template.content
        newDiary.rtfd = template.rtfd
        newDiary.containsImage = template.containsImage
        newDiary.scalableImageModels = template.scalableImageModels.map({ oldModel in
            return oldModel.copy()
        })
        newDiary.lwTodoModels = template.lwTodoModels.map({ oldModel in
            return oldModel.copy()
        })
       
        // 保存&上传
        LWRealmManager.shared.add(newDiary)
        DiaryStore.shared.addOrUpdate(newDiary)
        
        return newDiary
    }
}
