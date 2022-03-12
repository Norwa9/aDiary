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
    func getTemplateFor(templateName:String?) -> [diaryInfo]{
        //TODO: 模板名称不能超过主键最长字符数
        if let templateName = templateName {
            // 返回查询模板
            let queryName = TemplateNamePrefix + templateName
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
    func modifyTempalteName(oldTemplateName:String,newTemplateName:String){
        if let template = getTemplateFor(templateName: oldTemplateName).first{
            LWRealmManager.shared.update(updateBlock: {
                //TODO: 模板名称不能超过主键最长字符数
                template.date = TemplateNamePrefix + newTemplateName
            })
        }
    }
    
    /// 删除
    func deleteTemplate(templateName:String){
        if let template = getTemplateFor(templateName: templateName).first{
            DiaryStore.shared.delete(with: template.id)
        }
    }
    
    
    /// 使用模板（读取模板）
    /// pageIndex=0时表示创建主日记
    /// pageIndex>0时表示在日记内创建新的页
    func createDiaryUsingTemplate(dateCN:String,pageIndex:Int,templateName:String) -> diaryInfo?{
        // 拷贝
        guard let template = self.getTemplateFor(templateName: templateName).first else{
            return nil
        }
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
