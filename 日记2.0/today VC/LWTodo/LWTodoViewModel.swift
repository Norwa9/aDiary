//
//  LWTodoViewModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/24.
//

import Foundation
import UIKit
import SubviewAttachingTextView

class LWTodoViewModel:NSObject{
    var location:Int
    var bounds:CGRect
    var state:Int = 0
    var content:String = ""
    var note:String = ""
    var needRemind:Bool = false
    var remindDate:Date = Date()
    var uuid:String
    
    weak var lwTextView:LWTextView?
    
    var todoViewStyle:Int = 0//0表示在textView中显示、1表示在todoListView中显示
    weak var todoListView:TodoListView?
    
    //MARK: getter
    var hasExtroInfo:Bool{
        get{
            return (needRemind || note != "")
        }
    }
    
    /// 返回todo文本的属性文本
    var todoFont:UIFont {
        get{
            if todoViewStyle == 1{
                return userDefaultManager.monthCellTitleFont
            }
            return userDefaultManager.font
            
        }
    }
    
    /// 返回附属信息属性文本
    var extroInfoLabelFont:UIFont {
        get{
            if todoViewStyle == 1{
                return UIFont(name: "DIN Alternate", size: 10)!
            }
            return userDefaultManager.customFont(withSize: userDefaultManager.fontSize * 0.6)
            
        }
    }
    
    
    //MARK: init
    /// 读取日记时，创建viewModel
    init(model:LWTodoModel){
        self.location = model.location
        let bounds = CGRect.init(string: model.bounds)
        ?? globalConstantsManager.shared.defaultTodoBounds
        self.bounds = bounds
        self.state = model.state
        self.content = model.content
        self.note = model.note
        self.needRemind = model.needRemind
        self.remindDate = model.remindDate
        self.uuid = model.uuid
    }
    
    /// 插入todo时，创建viewModel
    init(location:Int){
        self.location = location
        self.bounds = globalConstantsManager.shared.defaultTodoBounds
        self.uuid = UUID().uuidString
    }
    
    func generateModel() -> LWTodoModel{
        let model = LWTodoModel(location: location, bounds: bounds, state: state, remindDate: remindDate, content: content, note: note, needRemind: needRemind,uuid: uuid)
        return model
    }
    
    typealias completionType = ()->(Void)
    ///view的location发生变化后，计算新的location
    func getNewestLocation(attributedString:NSAttributedString,completion:completionType){
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttribute(.attachment, in: fullRange, options: []) { object, range, stop in
            if let attchment = object as? SubviewTextAttachment{
                if let view = attchment.viewProvider.instantiateView(for: attchment, in: SubviewAttachingTextViewBehavior.init()) as? LWTodoView{
                    if view.viewModel == self{
                        let newestLocation = range.location
                        self.location = newestLocation
                        print("newest todo location : \(newestLocation)")
                        completion()
                        stop.pointee = true
                        return
                    }
                }
                
            }
        }
    }
    
    
    
    //MARK: 为view准备数据
    /// 为contentLabel返回属性文本
    func getTodoContent()->NSAttributedString?{
        if content == ""{
            return nil
        }
        if state == 1{ // 已完成，则添加划线，施加灰色字体颜色
            let doneAttributes:[NSAttributedString.Key : Any] = [
                .strikethroughStyle : 1,
                .strikethroughColor : UIColor.systemGray,
                .font : todoFont,
                .foregroundColor : UIColor.systemGray
            ]
            let doneContentAttrString = NSAttributedString(string: content,attributes: doneAttributes)
            return doneContentAttrString
        }else{
            let notdoneAttributes:[NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.label,
                .font : todoFont,
            ]
            return NSAttributedString(string: content,attributes: notdoneAttributes)
        }
    }
    
    func getAttributedPlaceHolder()->NSAttributedString{
        let placeHolderAttributes:[NSAttributedString.Key : Any] = [
            .font : todoFont,
            .foregroundColor : UIColor.systemGray
        ]
        return NSAttributedString(string: "添加待办事项",attributes: placeHolderAttributes)
    }
    
    /// 返回完成状态图标
    func getStateIcon()->UIImage?{
        var stateImg:UIImage?
        if self.state == 0{
            stateImg = UIImage(named: "checkbox_empty")
        }else if self.state == 1{
            stateImg = UIImage(named: "checkbox")
        }
        return stateImg
    }
    
    /// 返回提醒时间
    func getExtroInfoText()->NSAttributedString?{
        if !hasExtroInfo{
            return nil
        }
        let extroInfoMuAttrText = NSMutableAttributedString()
        if needRemind{
            let dateAttrString = remindDate.toYYMMDD_CN(font: extroInfoLabelFont)
            print("toYYMMDD_CN:\(dateAttrString.string)")
            extroInfoMuAttrText.append(dateAttrString)
        }
        if note != ""{
            let hasNoteAttrStringAttributes:[NSAttributedString.Key : Any] = [
                .font : extroInfoLabelFont,
                .foregroundColor : UIColor.secondaryLabel
            ]
            let hasNoteAttrString = NSAttributedString(string: "  📄有备注",attributes: hasNoteAttrStringAttributes)
            extroInfoMuAttrText.append(hasNoteAttrString)
        }
        return extroInfoMuAttrText
    }
    
    //MARK: 对view进行操作
    /// 在todo内按回车时
    func dealWithEnterTapped(todoTextView textView:UITextView){
        if let lwTextView = lwTextView{
            self.getNewestLocation(attributedString: lwTextView.attributedText) {
                var newSelectedRange:NSRange? = nil
                if location + 2 < lwTextView.attributedText.length{
                    newSelectedRange = NSRange(location: location + 2 , length: 0)
                }else if location + 1 < lwTextView.attributedText.length{
                    newSelectedRange = NSRange(location: location + 1, length: 0)
                }else if location  < lwTextView.attributedText.length{
                    newSelectedRange = NSRange(location: location, length: 0)
                }
                
                guard let newSelectedRange = newSelectedRange else {
                    return
                }
                lwTextView.selectedRange = newSelectedRange
                if textView.text.length == 0{ // 1. 当前todo为空，回车后空焦点回到lwTextView
                    self.deleteTodoView()
                    lwTextView.becomeFirstResponder()
                    return
                }else{ // 2.当前todo不为空，回车后另起一行创建一个todo
                    let formatter = TextFormatter(textView: lwTextView)
                    formatter.insertTodoList()
                }
            }
        }
    }
    
    func saveTodo(){
        lwTextView?.textViewController?.save()
    }
    
    /// 刷新todoView
    func reloadTodoView(todoView:LWTodoView){
        bounds = todoView.calToDoViewBounds()
        lwTextView?.reloadTodoView(endView: todoView)
        self.saveTodo()
    }
    
    
    
    func deleteTodoView(){
        if let lwTextView = lwTextView {
            self.getNewestLocation(attributedString: lwTextView.attributedText) {
                lwTextView.textStorage.deleteCharacters(in: NSRange(location: location, length: 1))
                let location = location
                lwTextView.selectedRange = NSRange(location: location, length: 0)
                self.saveTodo()
            }
        }
    }
    
    func adjustTextViewInset(){
        if let bottomInset = globalConstantsManager.shared.bottomInset,let lwTextView = lwTextView{
            getNewestLocation(attributedString: lwTextView.attributedText) {
                let todoViewFrame = lwTextView.layoutManager.boundingRect(forGlyphRange: NSRange(location: location, length: 1), in: lwTextView.textContainer)
                lwTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset - 40, right: 0) // 减去toolbar的高度
                lwTextView.scrollRectToVisible(todoViewFrame, animated: true) // 对于attchmentView只能使用scrollRectToVisible，使用scrollRangeToVisible不准确
            }
            
        }
    }
    
    
    /// 在todoListView显示时，计算单行的高度
    func calSingleRowTodoViewHeihgt()->CGFloat{
        var height = 0.0
        height = todoFont.lineHeight +  2.0 * 2.0 + 2.0
        if hasExtroInfo{
            height += extroInfoLabelFont.lineHeight
        }
        return height
    }
    
    /// 保存viewModel的变动到diaryinfo，然后刷新monthCell的todoListView
    func saveAndupdateTodoListView(){
        if todoViewStyle == 1{
            let newestModel = generateModel()
            if let diary = todoListView?.diary{
                // 更新数组中的该元素
                var todoModels = diary.lwTodoModels
                guard let changedIndex = todoModels.firstIndex(where: { model in
                    model.uuid == newestModel.uuid
                })else{
                    return
                }
                todoModels[changedIndex] = newestModel
                LWRealmManager.shared.update {
                    diary.lwTodoModels = todoModels
                }
                DiaryStore.shared.addOrUpdate(diary)
                
                todoListView?.updateViewHeightAndReloadData(newestDiary: diary,specifiedTodoUUID: newestModel.uuid)
                
                
            }
        }
    }
}
