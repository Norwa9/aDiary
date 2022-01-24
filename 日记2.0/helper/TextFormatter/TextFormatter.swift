//
//  TextFormatter.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/11.
//

import Foundation
import UIKit
import JXPhotoBrowser
import SubviewAttachingTextView
import Colorful

public class TextFormatter{
    private var textView: LWTextView
    private var storage: NSTextStorage
    private var range: NSRange//TextFormatter实例创建时，用户所选取的range
    private var selectedRange:NSRange
    
    init(textView: LWTextView){
        self.textView = textView
        self.range = textView.selectedRange
        self.storage = textView.textStorage
        self.selectedRange = textView.selectedRange
    }
    
    
    
//MARK: -MarkDown：Number List
    //创建数字列表
    func insertOrderedList(){
        //获取当前range所在段落的range
        guard let pRange = getCurParagraphRange() else { return }
        //print("pRange:\(pRange)")
        //获取当前段落的所有字符
        let paraMutableString = NSMutableAttributedString(attributedString: textView.attributedText.attributedSubstring(from: pRange))
        let paragraphString = paraMutableString.string
        //print("paragraphString:\(paragraphString)")
        
        guard paragraphString != "\n"  else {
            //如果当前段落只有数字或是空段落，那么插入首个序号
            //print("insertText(1.)")
            insertText("1. ")
            updateNumList(curParaRange: pRange, curDigit: 0)
            return
        }
        
        //检查paragraphString是否有数字前缀，如果没有，则需要添加前缀
        let shouldAddPrefix = !self.hasPrefix(line: paragraphString)
        
        //更新后续段落的序号：如果是将序号删除，则将之后的每段从1开始编号。如果是添加序号，则将下一段从0开始编号
        updateNumList(curParaRange: pRange, curDigit: shouldAddPrefix ? 1 : 0)
        
        var result = String()
        if shouldAddPrefix{
            //如果该段落没有序号，设置序号
            var empty = String()
            empty.append("1. ")
            result = empty + paragraphString
        }else{
            // 如果该段落已经有序号了，则把序号删除
            result = getCleanLine(line: paragraphString)
        }
        let l = paragraphString.contains("\n") ? pRange.location + result.count - 1 : pRange.location + result.count
        let selectRange = NSRange(location: l, length: 0)
        
        //将pRange替换成result，然后定位光标到selectRange
        insertText(result, replacementRange: pRange, selectRange: selectRange)
        
        
        
    }
    
    //MARK: 自动补齐todo列表和数字列表
    func addNewLine(){
        guard let currentParagraphRange = self.getCurParagraphRange() else { return }
        let currentParagraph = storage.attributedSubstring(from: currentParagraphRange)
        let selectedRange = self.textView.selectedRange
       
        // 1.自动补齐todo列表
        if selectedRange.location != currentParagraphRange.location && currentParagraphRange.upperBound - 2 < selectedRange.location, currentParagraph.length >= 2 {

            if textView.selectedRange.upperBound > 2 {
                let char = storage.attributedSubstring(from: NSRange(location: textView.selectedRange.upperBound - 2, length: 1))

                if let _ = char.attribute(.todo, at: 0, effectiveRange: nil) {
                    //按回车取消unchecked box
                    let selectRange = NSRange(location: currentParagraphRange.location, length: 0)
                    insertText("\n", replacementRange: currentParagraphRange, selectRange: selectRange)
                    textView.setDefaultTypingAttributes()
                    return
                }
            }

            var todoLocation = -1
            currentParagraph.enumerateAttribute(.todo, in: NSRange(0..<currentParagraph.length), options: []) { (value, range, stop) -> Void in
                guard value != nil else { return }

                todoLocation = range.location
                stop.pointee = true
            }

            if todoLocation > -1 {
                let unchecked = AttributedBox.getUnChecked()?.attributedSubstring(from: NSRange(0..<2))
                var prefix = String()

                if todoLocation > 0 {
                    prefix = currentParagraph.attributedSubstring(from: NSRange(0..<todoLocation)).string
                }

                let selectedRange = textView.selectedRange
                let selectedTextRange = textView.selectedTextRange!
                let checkbox = NSMutableAttributedString(string: "\n" + prefix)
                checkbox.append(unchecked!)
                checkbox.addAttributes([
                    .font : userDefaultManager.font,
                    .foregroundColor : UIColor.label,
                ])

                textView.undoManager?.beginUndoGrouping()
                textView.replace(selectedTextRange, withText: checkbox.string)
                textView.textStorage.replaceCharacters(in: NSRange(location: selectedRange.location, length: checkbox.length), with: checkbox)
                textView.setDefaultTypingAttributes()
                textView.undoManager?.endUndoGrouping()
                return
            }
        }
        
        //2.自动递增数字列表
        if selectedRange.location != currentParagraphRange.location{
            //获取例如4. 这样的前缀
            if let digitsMatch = TextFormatter.getAutocompleteDigitsMatch(string: currentParagraph.string) {
                self.matchDigits(string: currentParagraph, match: digitsMatch)
                return
            }
        }
        
        //不符合上面的条件，简单地换行即可
        insertText("\n")
    }
    
    //当清空某一行后，对其后所有的数字序号更新
    func correctNum(){
        if let curParaRange = getCurParagraphRange(),let nextParaRange = getNextParaRange(curParaRange: curParaRange){
            let nextPara = storage.attributedSubstring(from: nextParaRange)
            //如果下一段匹配到序号，则从下一段开始更新序号，直到遇到一个空行
            //序号从1重新排序
            if let _ = TextFormatter.getAutocompleteDigitsMatch(string: nextPara.string){
                self.updateNumList(curParaRange: curParaRange, curDigit: 0)
            }
        }
    }
    
    //当删除某一行时，对其后的所有数字序号更新
    func correctNum(deleteRange:NSRange){
        guard let curParaRange = getCurParagraphRange() else{return}
        let deleteParaRange = storage.mutableString.paragraphRange(for: deleteRange)
        //curPara删除前光标所在行
        //deletePara删除后光标所在行
        if curParaRange != deleteParaRange{
            let deleteParaRange = storage.attributedSubstring(from: deleteParaRange)
            if let match = TextFormatter.getAutocompleteDigitsMatch(string: deleteParaRange.string){
                let resultString = deleteParaRange.attributedSubstring(from: match.range).string
                if let digit = Int(resultString.replacingOccurrences(of:"[^0-9]", with: "", options: .regularExpression)){
                    updateNumList(curParaRange: curParaRange, curDigit: digit)
                }
            }
        }
        
    }
}
//MARK:  -todo复选框
extension TextFormatter{
    public func insertTodoList(){
        //selectedRange可能覆盖到【多个段落】
        guard let pRange = getCurParagraphRange() else{return}
        
        let attributedString = textView.attributedText.attributedSubstring(from: pRange)
        //为啥叫做为了方便后续的处理，先将名为.todo文本附件替换为占位符"- []"
        let mutable = NSMutableAttributedString(attributedString: attributedString).unLoadCheckboxes()
        
        //段落为空
        if !attributedString.hasTodoAttribute() && selectedRange.length == 0{
            insertText(AttributedBox.getUnChecked()!)
            return
        }
        
        //分析每一段，
        //1.若所有段落都没有未完成[]或完成[x]的占位符，则需要将每一段都加未完成占位符[]
        //2.若存在段落有未完成[]，则把每一段都加完成占位符[x]
        //3.parseTodo返回的是去除占位符的纯文本
        var lines = [String]()
        var addPrefixes = false
        var addCompleted = false
        let string = mutable.string
        
        string.enumerateLines { (line, _) in
            let result = TextFormatter.parseTodo(line: line)
            addPrefixes = !result.0
            addCompleted = result.1
            lines.append(result.2)
        }

        var result = String()
        for line in lines {
            if addPrefixes {
                let task = addCompleted ? "- [x] " : "- [ ] "
                var empty = String()
                var scanFinished = false

                if line.count > 0 {
                    for char in line {
                        if char.isWhitespace && !scanFinished {
                            empty.append(char)
                        } else {
                            if !scanFinished {
                                empty.append(task + "\(char)")
                                scanFinished = true
                            } else {
                                empty.append(char)
                            }
                        }
                    }

                    result += empty + "\n"
                } else {
                    result += task + "\n"
                }
            } else {
                result += line + "\n"
            }
        }

        let mutableResult = NSMutableAttributedString(string: result)
        //print("mutableResult.length:\(mutableResult.length),result:\(result)")
        
        //将占位符"- []"替换为名为.todo文本附件
        mutableResult.loadCheckboxes()
        mutableResult.addAttribute(.font, value: userDefaultManager.font, range: NSRange(location: 0, length: mutableResult.length))
        
        //将新文本插入
        let diff = mutableResult.length - attributedString.length
        let selectRange = selectedRange.length == 0 || lines.count == 1
            ? NSRange(location: pRange.location + pRange.length + diff - 1, length: 0)
            : NSRange(location: pRange.location, length: mutableResult.length)
        insertText(mutableResult, replacementRange: pRange, selectRange: selectRange)
    }
    
    ///解析每一段文字，检查其去除空白开头后是否还有todo占位符 "- []" 或"- [x]"
    ///此外，还返回去除占位符的纯文本或含有占位符的纯文本
    static func parseTodo(line: String) -> (Bool, Bool, String, String) {
        var count = 0
        var hasTodoPrefix = false
        var hasIncompletedTask = false
        var charFound = false
        var whitespacePrefix = String()
        var letterPrefix = String()

        //1.获取空白前缀whitespacePrefix
        //2.获取剔除空白后的字母letterPrefix
        for char in line {
            if char.isWhitespace && !charFound {
                count += 1
                whitespacePrefix.append(char)
                continue
            } else {
                charFound = true
                letterPrefix.append(char)
            }
        }

        //去除空白的字符前缀是否有占位符开头
        if letterPrefix.starts(with: "- [ ] ") {
            hasTodoPrefix = false
            hasIncompletedTask = true
        }

        if letterPrefix.starts(with: "- [x] ") {
            hasTodoPrefix = true
        }

        let checkPrefix = letterPrefix
        
        //取出所有占位符
        letterPrefix =
            letterPrefix
                .replacingOccurrences(of: "- [ ] ", with: "")
                .replacingOccurrences(of: "- [x] ", with: "")

        return (hasTodoPrefix, hasIncompletedTask, whitespacePrefix + letterPrefix,checkPrefix)
    }
    
    ///反转todo属性
    public func todoTapped(location:Int,todoAttr:Int) {
        let attributedText = (todoAttr == 0) ? AttributedBox.getChecked() : AttributedBox.getUnChecked()

        self.textView.undoManager?.beginUndoGrouping()
        self.storage.replaceCharacters(in: NSRange(location: location, length: 1), with: (attributedText?.attributedSubstring(from: NSRange(0..<1)))!)
        self.textView.undoManager?.endUndoGrouping()

        // todo所在的段落
        guard let todoParagraph = getParagraphRange(for: location) else { return }
        
        if todoAttr == 0 {
            self.storage.addAttribute(.strikethroughStyle, value: 1, range: todoParagraph)
            self.storage.addAttribute(.foregroundColor, value: UIColor.systemGray, range: todoParagraph)
        } else {
            self.storage.removeAttribute(.strikethroughStyle, range: todoParagraph)
            self.storage.addAttribute(.foregroundColor, value: UIColor.label, range: todoParagraph)
        }
        
        guard let curParagraph = getParagraphRange(for: self.textView.selectedRange.location) else{ return }
        if curParagraph.contains(location) {
            print("paragraph.contains(location):\(location)")
            let strike = (todoAttr == 0) ? 1 : 0
            let color = (todoAttr == 0) ? UIColor.systemGray : UIColor.label
            textView.typingAttributes[.foregroundColor] = color
            textView.typingAttributes[.strikethroughStyle] = strike
        }
    }
    
}

//MARK :-helper
extension TextFormatter{
    //获取当前选取文字所在的段落
    func getCurParagraphRange() -> NSRange? {
        if range.upperBound <= storage.length {
            let paragraphRange = storage.mutableString.paragraphRange(for: range)
            return paragraphRange
        }
        
        return nil
    }
    
    private func getParagraphRange(for location: Int) -> NSRange? {
        guard location <= storage.length else { return nil}

        let range = NSRange(location: location, length: 0)
        let paragraphRange = storage.mutableString.paragraphRange(for: range)
        
        return paragraphRange
    }
    
    func getCurParaString()->String?{
        if range.upperBound <= storage.length {
            let paragraphRange = storage.mutableString.paragraphRange(for: range)
            let paraString = storage.attributedSubstring(from: paragraphRange).string
            return paraString
        }
        
        return nil
    }
    
    //使用当前段落的pRange，获取下一段落的pRange
    func getNextParaRange(curParaRange:NSRange)->NSRange?{
        if curParaRange.upperBound < storage.length{
            let nextParaBegan = NSRange(location: curParaRange.upperBound, length: 0)
            //着一段的upperBound就是下一段的开头
            let nextParaRange = storage.mutableString.paragraphRange(for: nextParaBegan)
//            print("curParaRange:\(curRange),nextParaBegan:\(nextParaBegan)nextParaRange:\(nextParaRange)")
            return nextParaRange
        }
        return nil
    }
    
    public static func getAutocompleteDigitsMatch(string: String) -> NSTextCheckingResult? {
        guard let regex = try? NSRegularExpression(pattern: "^(( |\t)*[0-9]+\\. )"), let result = regex.firstMatch(in: string, range: NSRange(0..<string.count)) else { return nil }

        return result
    }
    
    private func matchDigits(string: NSAttributedString, match: NSTextCheckingResult) {
        //string是本段文字
        guard string.length >= match.range.upperBound else { return }

        //found是匹配到序号的的纯文本，例如"4. "
        let found = string.attributedSubstring(from: match.range).string
        var newLine = 1

        if textView.selectedRange.upperBound == storage.length {
            newLine = 0
        }

        
        //如果当前序号后面没有有效内容，则换行时将把本段清空，并把光标置回本段开头
        if found.count + newLine == string.length {
            
            //1.更新后续段落的序号从1开始
            if let curRange = self.getCurParagraphRange(){
                updateNumList(curParaRange: curRange, curDigit: 0)
            }
            //2.清空该行
//            print("清空一行")
            let range = storage.mutableString.paragraphRange(for: textView.selectedRange)
            let selectRange = NSRange(location: range.location, length: 0)
            insertText("\n", replacementRange: range, selectRange: selectRange)
            return
        }

        //将数字提取，使用递增数字作为下一行的序号
        if let position = Int(found.replacingOccurrences(of:"[^0-9]", with: "", options: .regularExpression)) {
            //1.获取新序号所在段落以及序号p，然后更新其后所有的段落从p+2开始
            if let curRange = self.getCurParagraphRange(){
//                let curPara = storage.attributedSubstring(from: curRange).string
//                print("curRange:\(curPara)")
                updateNumList(curParaRange: curRange, curDigit: position + 1)
            }
            
            //2.在当前段落的下一段插入p+1. exaple
//            print("插入新序号")
            let newDigit = found.replacingOccurrences(of: String(position), with: String(position + 1))
            insertText("\n" + newDigit)
        }
        
        
            
    }
    
    func updateNumList(curParaRange:NSRange,curDigit:Int){
        guard let nextRange = getNextParaRange(curParaRange: curParaRange) else{return}
        let nextParagraphAttrString = storage.attributedSubstring(from: nextRange)
        let nextParagraphString = nextParagraphAttrString.string
        if nextParagraphString == "\n"{
            return
        }
        print("\(curDigit)updateNumList,nextPara:\(nextParagraphString),count:\(nextParagraphString.count)")
        
        //搜索下一行开头的序号
        guard let matchDigit = Int(nextParagraphString.replacingOccurrences(of:"[^0-9]", with: "", options: .regularExpression))else{return}
        //替换序号
        let newNextParaString = nextParagraphString.replacingOccurrences(of: String(matchDigit), with: String(curDigit + 1))
        storage.replaceCharacters(in: nextRange, with: newNextParaString)
        
        //例如9. example被替换成10. example后，nextRange有变化，不能直接传入updateNumList()
        let newRange = NSRange(location: nextRange.location, length: newNextParaString.count)
        //递归对下一行进行检查替换
        updateNumList(curParaRange: newRange, curDigit: curDigit + 1)
        
    }
    
    //往textView中插入指定内容，然后调整光标位置。
    //是一个很好用的辅助函数
    private func insertText(_ string: Any, replacementRange: NSRange? = nil, selectRange: NSRange? = nil) {
        //replacementRange表示当前段落
        //如果replacementRange为空，
        let range = replacementRange ?? self.textView.selectedRange
        
        guard
            let start = textView.position(from: self.textView.beginningOfDocument, offset: range.location),
            let end = textView.position(from: start, offset: range.length),
            let selectedRange = textView.textRange(from: start, to: end)
        else { return }
    
        var replaceString = String()
        if let attributedString = string as? NSAttributedString {
            replaceString = attributedString.string
        }
    
        if let plainString = string as? String {
            replaceString = plainString
        }
    
        self.textView.replace(selectedRange, withText: replaceString)

        if let string = string as? NSAttributedString {
            storage.replaceCharacters(in: NSRange(location: range.location, length: replaceString.count), with: string)
        }

        //段落样式
        let parRange = NSRange(location: range.location, length: replaceString.count)
        let parStyle = NSMutableParagraphStyle()
        parStyle.alignment = .left
        parStyle.lineSpacing = CGFloat(userDefaultManager.lineSpacing)
        let attributes: [NSAttributedString.Key:Any] = [
            .font:userDefaultManager.font,
            .paragraphStyle : parStyle,
            .foregroundColor : UIColor.label,//注释掉，防止已完成的todo的灰色字体又变成黑色
        ]
        self.textView.textStorage.addAttributes(attributes, range: parRange)
        
        //设定光标位置
        if let select = selectRange {
            textView.selectedRange = select
        }
    }
    
    //检查前缀：是否有诸如"4."这样的数字序号前缀
    private func hasPrefix(line: String) -> Bool {
        var checkNumberDot = false

        //例如4. example中，检查到"4."即return true
        for char in line {
            if checkNumberDot {
                if char == "." {
                    return true
                }
            }

            if char.isWhitespace {
                continue
            } else {
                if char.isNumber {
                    checkNumberDot = true
                    continue
                }
            }
        }

        return false
    }
    
    //清洗一个有"-"或"4. "等前缀的字符串
    private func getCleanLine(line: String) -> String {
        var cleanLine = String()
        var prefixFound = false

        var numberCheck = false
        var spaceCheck = false
        var dotCheck = false

        var skipped = String()

        for char in line {
            if numberCheck {
                if char.isNumber {
                    skipped.append(char)
                    continue
                } else {
                    numberCheck = false
                    dotCheck = true
                }
            }

            if dotCheck {
                if char == "." {
                    skipped.append(char)
                    spaceCheck = true
                } else {
                    cleanLine.append(skipped)
                    cleanLine.append(char)
                    skipped = ""
                }

                dotCheck = false
                continue
            }

            if spaceCheck {
                if char.isWhitespace {
                } else {
                    cleanLine.append(skipped)
                    cleanLine.append(char)
                }

                spaceCheck = false
                skipped = ""
                continue
            }

            if char.isWhitespace && !prefixFound {
                cleanLine.append(char)
            } else if !prefixFound {
                if char.isNumber {
                    numberCheck = true
                    skipped.append(char)
                } else if char == "-" {
                    spaceCheck = true
                    skipped.append(char)
                } else {
                    cleanLine.append(char)
                }
                prefixFound = true
            } else {
                cleanLine.append(char)
            }
        }

        if skipped.count > 0 {
            cleanLine.append(skipped)
        }

        return cleanLine
    }
    
}

//MARK:  -插入图片、时间戳
extension TextFormatter{
    ///插入时间戳
    func insertTimeTag(){
        textView.setDefaultTypingAttributes()
        //获取当前时间，格式：-H:mm-
        let formatter = DateFormatter()
        formatter.dateFormat = "-H:mm-"
        let time = formatter.string(from: Date())
        
        textView.insertText(time)
    }
    
    func calculateDocumentSize(_ completion:(_ available:Bool)->()){
        let allRange = NSRange(location: 0, length: textView.attributedText.length)
        var roughlySize:Int = 0
        self.textView.attributedText.enumerateAttribute(.attachment, in: allRange, options: []) { object, range, stop in
            if let attchment = object as? SubviewTextAttachment,let view = attchment.view as? ScalableImageView{
                if let imageData = view.viewModel.image?.jpegData(compressionQuality: 1){
                    roughlySize += imageData.count
                }
            }
        }
        print("插入图片前，所有图片的大小：\(roughlySize)")
    }
    
    ///插入可变大小图片
    func insertScalableImageView(image:UIImage){
        let location = selectedRange.location
        //插入换行
        let Linebreak = NSMutableAttributedString(string: "\n")
        let LinebreakAttributedString = Linebreak.addingAttributes([
            .font : userDefaultManager.font,
            .foregroundColor : UIColor.label
        ])
        textView.textStorage.insert(LinebreakAttributedString, at: location)
        
        //插入图片
        let defaultViewModel = ScalableImageViewModel(location: location, image: image)
        let view = ScalableImageView(viewModel: defaultViewModel)
        view.delegate = textView
        let subViewAttchment = SubviewTextAttachment(view: view, size: defaultViewModel.bounds.size)
        textView.textStorage.insertAttachment(subViewAttchment, at: location + 1, with: imageCenterParagraphStyle)
        textView.textStorage.addAttribute(.image, value: 1, range: NSRange(location: location + 1, length: 1))//别忘了添加.image key
        
        //插入换行
        textView.textStorage.insert(LinebreakAttributedString, at: location + 2)
        
        //更新焦点
        textView.selectedRange = NSRange(location: location + 3, length: 0)
        textView.scrollRangeToVisible(textView.selectedRange)
        textView.setLeftTypingAttributes()
        
        
        let undo = Undo(range: NSRange(location: location, length: 3), attchment: subViewAttchment)
        self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
            self.undoImage(undo)
        })
    }
    
    struct Undo {
        var range: NSRange
        var attchment: SubviewTextAttachment
    }
    
    // 插入图片后撤回
    @objc func undoImage(_ object: Any){
        guard let undo = object as? Undo else { return }

        textView.textStorage.deleteCharacters(in: undo.range)
        textView.selectedRange = NSRange(location: undo.range.location, length: 0)
        textView.setLeftTypingAttributes()
        
        let redo = Undo(range: undo.range, attchment: undo.attchment)

        self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
            self.redoImage(redo)
        })
    }
    
    @objc func redoImage(_ object: Any){
        guard let redo = object as? Undo else { return }
        
        let Linebreak = NSMutableAttributedString(string: "\n")
        let LinebreakAttributedString = Linebreak.addingAttributes([
            .font : userDefaultManager.font,
            .foregroundColor : UIColor.label
        ])
        textView.textStorage.insert(LinebreakAttributedString, at: redo.range.location)
        textView.textStorage.insertAttachment(redo.attchment, at: redo.range.location + 1, with: imageCenterParagraphStyle)
        textView.textStorage.addAttribute(.image, value: 1, range: NSRange(location: redo.range.location + 1, length: 1))//添加.image key
        textView.textStorage.insert(LinebreakAttributedString, at: redo.range.location + 2)
        textView.selectedRange = NSRange(location: redo.range.location + 3, length: 0)
        textView.scrollRangeToVisible(textView.selectedRange)
        textView.setLeftTypingAttributes()

        let undo = Undo(range: redo.range, attchment: redo.attchment)

        self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
            self.undoImage(undo)
        })
    }
    
    
}


//MARK: -shouldInteractWith textAttachment
extension TextFormatter{
    func interactAttchment(with characterRange: NSRange,diary:diaryInfo)
    ->NSAttributedString.Key?{
        let location = characterRange.location
        
        //如果点击的是.todo文本属性
        if let todoAttrValue = storage.attribute(.todo, at: location, effectiveRange: nil) as? Int{
            self.todoTapped(location: location, todoAttr: todoAttrValue)
            return .todo
        }
        
        return nil
    }
}

//MARK: -保存
extension TextFormatter{
    ///根据日期信息将富文本存储到文件目录
    func save(with diary:diaryInfo){
        let attributedText = textView.attributedText!
        let result = attributedText.parseAttribuedText(diary: diary)
        let todoAttrTuples = result.0
        let text = result.1
        let containsImage = result.2
        let incompletedTodos = result.3
        let allTodos = result.5
        let imageModels = result.6
        let recoveredAttributedText = result.7
        
        let plainText = TextFormatter.parsePlainText(text: text,allTodos: allTodos)
        
        //1.保存到本地
        LWRealmManager.shared.update(updateBlock: {
            diary.editedButNotUploaded = true
            diary.modTime = Date()
            diary.content = plainText
            diary.todos = incompletedTodos
            
            let rtfd = recoveredAttributedText.toRTFD()
            rtfd?.printSize()
            diary.rtfd = rtfd
            
            diary.containsImage = containsImage
            diary.scalableImageModels = imageModels
            diary.todoAttributesTuples = todoAttrTuples
        })
        
        //2.上传到云端
        DiaryStore.shared.addOrUpdate(diary)
        
        
    }
    
    
    /*
     1.替换图片的占位符"P"
     2.删除头部和尾部多余的空格
     3.去除所有todo条目
     */
    ///处理纯文本
    static func parsePlainText(text:String,allTodos:[String])->String{
        var res:String
        //替换图片的占位符"P"
        res = text.replacingOccurrences(of: "P\\b", with: "[图片]",options: .regularExpression)
        //去除所有todo条目
        for todo in allTodos{
            let todoWithoutLineBreak = todo.trimmingCharacters(in: .whitespacesAndNewlines)
            let todoWithLineBreak = todoWithoutLineBreak + "\n"
            if todo == allTodos.last{
                res = res.replacingOccurrences(of: todoWithoutLineBreak, with: "")
            }else{
                res = res.replacingOccurrences(of: todoWithLineBreak, with: "")
            }
        }
        //最后删除头部和尾部多余的空格
        res = res.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return res
    }
    
}

//MARK: -读取
extension TextFormatter{
    func loadTextViewContent(with diary:diaryInfo){
        textView.setDefaultTypingAttributes()
        let cleanContent = diary.content
        let rtfd = diary.rtfd
        let imageModels = diary.scalableImageModels
        let todoAttrTuples = diary.todoAttributesTuples
        
        DispatchQueue.global(qos: .default).async {
            let attributedText:NSAttributedString = LoadRTFD(rtfd: rtfd) ?? NSAttributedString(string: cleanContent)//rtfd文件非常耗时，后台读取
            //TODO:当用cleanContent替代rtfd时，遍历attribute有可能崩溃
            let correctedAString = self.processAttrString(
                aString:attributedText,
                todoAttrTuples: todoAttrTuples,
                imageModels: imageModels
            )
            DispatchQueue.main.async {
                self.textView.attributedText = correctedAString
            }
        }
    }
    
    ///读取富文本，并为图片附件设置正确的大小、方向
    ///textViewScreenshot
    ///loadTextViewContent(with:)
    func processAttrString(aString:NSAttributedString,
                           todoAttrTuples:[(Int,Int)],
                           imageModels:[ScalableImageModel],
                           isSharingMode:Bool =  false
    )->NSMutableAttributedString{
        
        let mutableText = NSMutableAttributedString(attributedString: aString)
        //1、恢复字体
        let attrText = mutableText.restoreFontStyle()
        
        //2.恢复.image格式
        for model in imageModels{
            let location = model.location
            if isSharingMode{
                // 分享or导出时，需要与调用方在同一个线程，不能被main.async包裹。
                // 否者，replaceAttchment还未完成，就会先执行return attrText
                let viewModel = ScalableImageViewModel(model: model)
                let view = ScalableImageView(viewModel: viewModel)
                let viewSnapShot = view.asImage() // 将ScalableImageView截屏然后塞入attchment
                let replacingAttchment = NSTextAttachment(image: viewSnapShot, size: viewModel.bounds.size)
                attrText.replaceAttchment(replacingAttchment, attchmentAt: location, with: viewModel.paraStyle)
            }else{
                DispatchQueue.main.async {
                    let viewModel = ScalableImageViewModel(model: model)
                    let view = ScalableImageView(viewModel: viewModel)
                    view.delegate = self.textView
                    let subViewAttchment = SubviewTextAttachment(view: view, size: view.size)
                    attrText.replaceAttchment(subViewAttchment, attchmentAt: viewModel.location, with: viewModel.paraStyle)
                    //重新添加.image属性（用于保存时检索图片attchment）
                    attrText.addAttribute(.image, value: 1, range: NSRange(location: location, length: 1))
                }
            }
            
            
            /*
             备忘：不同版本的图片管理方式。
             1.旧版本(2.6~3.1)，图片是存放在attributedText里的，同时借助imageAttrTuples和imageModels来恢复图片
             2.旧版本(<2.6)，图片直接存放在attributedText，只有imageAttrTuples来定位哪个NSAttchment是图片还是todo，此时还没有图片ViewModel的概念，如果在新版本访问到2.6版本之前保存的日记，需要根据imageAttrTuples手动遍历出NSAttchment，然后给它创建一个viewModel来管理它的尺寸、排版等（>3.1放弃了对它们的处理2022.1.21，待填坑）
             3.新版本(>3.1)里，图片存放在Realm，通过uuid索引
             */
        }
        
        //TODO:3.恢复todo
        for tuple in todoAttrTuples{
            let location = tuple.0//attribute location
            let value = tuple.1//attribute value
            if let attachment = attrText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment{
                //print("读取时处理到到todo:\(location)")
                //1.重新添加attribute
                attrText.addAttribute(.todo, value: value, range: NSRange(location: location, length: 1))
                
                let attributedText = (value == 1) ? AttributedBox.getChecked() : AttributedBox.getUnChecked()

                attrText.replaceCharacters(in: NSRange(location: location, length: 1), with: (attributedText?.attributedSubstring(from: NSRange(0..<1)))!)

                let range = NSRange(location: location, length: 0)
                let paragraphRange = attrText.mutableString.paragraphRange(for: range)
                
                if value == 1 {
                    attrText.addCheckAttribute(range: paragraphRange)
                } else {
                    attrText.addUncheckAttribute(range: paragraphRange)
                }
                
                //2.调整bounds大小
                let font = userDefaultManager.font
                let size = font.pointSize + font.pointSize / 2
                attachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - size) / 2, width: size, height: size)
            }
            
        }
        
        return attrText
    }
    
    
    ///屏幕旋转时，刷新textView的文本内容
    func reloadTextViewOnOrientionChange(with diary:diaryInfo){
        let imageModels = diary.scalableImageModels
        let todoAttrTuples = diary.todoAttributesTuples
        let attributedText = textView.attributedText ?? NSAttributedString(string: "")
        let correctedAString = self.processAttrString(
            aString:attributedText,
            todoAttrTuples: todoAttrTuples,
            imageModels: imageModels
        )
        self.textView.attributedText = correctedAString
    }
    
}

//MARK: -helper
extension TextFormatter{
    ///设置textView的Placeholder
    func setPlaceholder(){
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = userDefaultManager.lineSpacing
        let attributes:[NSAttributedString.Key:Any] = [
            .font:userDefaultManager.font,
            .paragraphStyle : paraStyle,
            .foregroundColor : UIColor.gray,
        ]
        let placeHolder = "标题.."
        self.textView.attributedText = NSAttributedString(string: placeHolder, attributes: attributes)
    }
}

//MARK: -分享长图、导出PDF
extension TextFormatter{
    func textViewScreenshot(diary:diaryInfo) -> UIImage{
        let attributedText = diary.attributedString
        let imageModels = diary.scalableImageModels
        let todoAttrTuples = diary.todoAttributesTuples
        
        
        let preparedText = self.processAttrString(
            aString:attributedText,
            todoAttrTuples: todoAttrTuples,
            imageModels: imageModels,
            isSharingMode: true
        )
        
        self.textView.attributedText = preparedText
        textView.layer.cornerRadius = 10
        textView.showsVerticalScrollIndicator = false
        //不能在原textView上进行截图，没办法把所有内容都截下来
        //除非在截图之前将textView.removeFromSuperview()
        let snapshot = textView.image()
        return snapshot
    }
    
    /*
     调和型函数
     旧版本存储的日记没有在磁盘中存储对应的富文本格式文件
     所以要先将其纯文本转换为富文本。
     */
    func rawtextToRichtext(diary:diaryInfo)->NSAttributedString{
        self.textView.text = diary.content
        let attrText = self.textView.attributedText.restoreFontStyle()
        self.textView.attributedText = attrText
        return attrText
    }
    
}

extension TextFormatter{
    enum fontTrait {
        case bold
        case italic
    }
    //MARK: -粗体或斜体
    func toggleTrait(On trait:fontTrait){
        let selectedRange = range
        if selectedRange.length > 0{
            var newFont:UIFont?
            let subAttributedString = storage.attributedSubstring(from: selectedRange)
            if let prevFont = subAttributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont{
                if trait == .bold{
                    newFont = toggleBoldFont(font: prevFont)
                }else{
                    newFont = toggleItalicFont(font: prevFont)
                }
                if let newFont = newFont{
                    textView.textStorage.addAttribute(.font, value: newFont, range: selectedRange)
                    
                    self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                        self.undoAttribute(key: .font, value1: prevFont, value2: newFont, applyRange: selectedRange)
                    })
                }
            }
        }else{
            let defaultFont =  textView.typingAttributes[.font] as! UIFont
            let newFont:UIFont?
            if trait == .bold{
                newFont = toggleBoldFont(font: defaultFont)
            }else {
                newFont = toggleItalicFont(font: defaultFont)
            }
            if let newFont = newFont,let prevFont = textView.typingAttributes[.font]{
                textView.typingAttributes[.font] = newFont
                
                self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                    self.undoAttribute(key: .font, value1: prevFont, value2: newFont, applyRange: NSRange(location: 0, length: 0))
                })
            }
        }
    }
    
    private func toggleBoldFont(font: UIFont) -> UIFont? {
        if (font.isBold) {
            return font.unBold()
        } else {
            return font.bold()
        }
    }
    
    private func toggleItalicFont(font: UIFont) -> UIFont? {
        if (font.isItalic) {
            return font.unItalic()
        } else {
            return font.italic()
        }
    }
    
    //MARK: -下划线
    func toggleUnderLine(){
        let selectedRange = range
        let curFontColor = getSelectedFontColor()
        if selectedRange.length > 0{
            let subAttributedString = storage.attributedSubstring(from: selectedRange)
            if let underLine = subAttributedString.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int{
                if underLine == 1{
                    storage.removeAttribute(.underlineStyle, range: selectedRange)
                }
                self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                    self.undoAttribute(key: .underlineStyle, value1: 1, value2: curFontColor, applyRange: selectedRange)
                })
            }else{
                //underLine == nil
                storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: selectedRange)
                storage.addAttribute(.underlineColor, value: curFontColor, range: selectedRange)
                self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                    self.undoAttribute(key: .underlineStyle, value1: 0, value2: curFontColor, applyRange: selectedRange)
                })
            }
        }else{
            print("selectedRange.length == 0 ")
            if (textView.typingAttributes[.underlineStyle] == nil) {
                textView.typingAttributes[.underlineStyle] = 1
                textView.typingAttributes[.underlineColor] = curFontColor
            } else {
                textView.typingAttributes.removeValue(forKey: .underlineStyle)
            }
        }
    }
    
    //MARK: -排版
    func setParagraphAligment(aligment:LWTextAligmentStyle){
        if let paraRange = getCurParagraphRange(){
            // 旧的排版
            let curAligment = getCurrentAligment()
            var prevStyle:NSMutableParagraphStyle
            switch curAligment {
            case .center:
                prevStyle = textCenterParagraphStyle
            case .left:
                prevStyle = textLeftParagraphStyle
            case .right:
                prevStyle = textRightParagraphStyle
            default:
                prevStyle = imageCenterParagraphStyle
            }
            
            // 新的排版
            var newStyle:NSMutableParagraphStyle
            switch aligment {
            case .center:
                newStyle = textCenterParagraphStyle
            case .left:
                newStyle = textLeftParagraphStyle
            case .right:
                newStyle = textRightParagraphStyle
            default:
                newStyle = imageCenterParagraphStyle
            }
            storage.addAttribute(.paragraphStyle, value: newStyle, range: paraRange)
            
            
            
            self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                self.undoAttribute(key: .paragraphStyle, value1: prevStyle, value2: newStyle, applyRange: paraRange)
            })
        }
    }
    
    func getCurrentAligment() -> LWTextAligmentStyle{
        if let pRange = getCurParagraphRange(){
            print("getCurrentAligment,pRange : \(pRange)")
            guard storage.length > 0, pRange.location < storage.length else{
                //在第一段或者最后一段调用下面的遍历，会发生奔溃
                return .left
            }
            if let paraStyle = storage.attribute(.paragraphStyle, at: pRange.location, effectiveRange: nil) as? NSParagraphStyle{
                if paraStyle.alignment == .left{
                    return .left
                }else if paraStyle.alignment == .right{
                    return .right
                }else{
                    return .center
                }
            }
        }
        return .left
    }
    
    //MARK: -字体颜色
    func changeFontColor(newColor:UIColor){
        let selectedRange = textView.selectedRange
        let curFontColor = getSelectedFontColor()
        if selectedRange.length > 0{
            //1.改字体颜色
            storage.addAttribute(.foregroundColor, value: newColor, range: selectedRange)
            //2.改下划线颜色
            if hasUnderLine(range: selectedRange){
                storage.addAttribute(.underlineColor, value: newColor, range: selectedRange)
            }
            self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                self.undoAttribute(key: .foregroundColor, value1: curFontColor, value2: newColor, applyRange: selectedRange)
            })
        }else{
            textView.typingAttributes[.foregroundColor] = newColor
            if (textView.typingAttributes[.underlineStyle] != nil) {
                textView.typingAttributes[.underlineColor] = newColor
            }
        }
    }
    
    func hasUnderLine(range:NSRange)->Bool{
        let subAttributedString = storage.attributedSubstring(from: range)
        if let underLine = subAttributedString.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int{
            if underLine == 1{
                return true
            }
        }
        return false
    }

    func getSelectedFontColor() -> UIColor{
        if selectedRange.length > 0{
            if let color = textView.attributedText.attribute(.foregroundColor, at: selectedRange.location, effectiveRange: nil) as? UIColor{
                return color
            }
            return .label
        }else{
            if let textColor = textView.typingAttributes[.foregroundColor] as? UIColor{
                return textColor
            }else{
                return .label
            }
        }
    }
    
    //MARK: -字体大小
    func changeFontSize(newFontSize:CGFloat){
        let selectedRange = range
        if selectedRange.length > 0{
            if let prevFont = storage.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont{
                let newFont = UIFont(descriptor: prevFont.fontDescriptor, size: newFontSize)
                storage.addAttribute(.font, value: newFont, range: selectedRange)
                
                self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
                    self.undoAttribute(key: .font, value1: prevFont, value2: newFont, applyRange: selectedRange)
                })
            }
        }else{
            guard storage.length > 0, range.location > 0 else { return  }
            let i = range.location - 1
            let upper = range.upperBound
            let substring = textView.attributedText.attributedSubstring(from: NSRange(i..<upper))
            if let prevFont = substring.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
                let newFont = UIFont(descriptor: prevFont.fontDescriptor, size: newFontSize)
                textView.typingAttributes[.font] = newFont
            }
        }
    }
    
    func getSelectedFontSize() -> CGFloat{
        if selectedRange.length > 0{
            if let font = textView.attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont{
                return font.pointSize
            }
            return userDefaultManager.fontSize
        }else{
            return userDefaultManager.fontSize
        }
    }
    
    
    //MARK: -获取所有属性
    func getLocationAttributes() -> [NSAttributedString.Key : Any]{
        guard storage.length > 0, range.location > 0 else {
            return textView.typingAttributes
        }
        let i = range.location - 1
        let upper = range.upperBound
        let substring = textView.attributedText.attributedSubstring(from: NSRange(i..<upper))
        return substring.attributes(at: 0, effectiveRange: nil)
    }
    
    
    func undoAttribute(key:NSAttributedString.Key ,value1: Any, value2: Any, applyRange: NSRange){
        // typingAttribute
        if applyRange.length != 0{
            if let old = value1 as? UIFont{
                textView.textStorage.addAttribute(.font, value: old, range: applyRange)
            }
            if let old = value1 as? Int,let curFontColor = value2 as? UIColor{
                if old == 0{
                    textView.textStorage.removeAttribute(.underlineStyle, range: applyRange)
                }else{
                    textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: applyRange)
                    textView.textStorage.addAttribute(.underlineColor, value: curFontColor, range: applyRange)
                }
            }
            if let old = value1 as? NSMutableParagraphStyle{
                textView.textStorage.addAttribute(.paragraphStyle, value: old, range: applyRange)
            }
            if let old = value1 as? UIColor{
                textView.textStorage.addAttribute(.foregroundColor, value: old, range: applyRange)
                if hasUnderLine(range: applyRange){
                    textView.textStorage.addAttribute(.underlineColor, value: old, range: applyRange)
                }
            }
        }else{
            
        }
        
        self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
            self.redoAttribute(key: key, value1: value1, value2: value2, applyRange: applyRange)
        })
    }
    
    func redoAttribute(key:NSAttributedString.Key ,value1: Any, value2: Any, applyRange: NSRange = NSRange(location: 0, length: 0)){
        // typingAttribute
        if applyRange.length != 0{
            if let new = value2 as? UIFont{
                textView.textStorage.addAttribute(.font, value: new, range: applyRange)
            }
            if let new = value1 as? Int,let curFontColor = value2 as? UIColor{
                if new == 1{
                    textView.textStorage.removeAttribute(.underlineStyle, range: applyRange)
                }else{
                    textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: applyRange)
                    textView.textStorage.addAttribute(.underlineColor, value: curFontColor, range: applyRange)
                }
            }
            if let new = value2 as? NSMutableParagraphStyle{
                textView.textStorage.addAttribute(.paragraphStyle, value: new, range: applyRange)
            }
            if let new = value2 as? UIColor{
                textView.textStorage.addAttribute(.foregroundColor, value: new, range: applyRange)
                if hasUnderLine(range: applyRange){
                    textView.textStorage.addAttribute(.underlineColor, value: new, range: applyRange)
                }
            }
        }else{
            
        }
        
        
        
        self.textView.undoManager?.registerUndo(withTarget: textView, handler: { (targetTextView) in
            self.undoAttribute(key: .font, value1: value1, value2: value2,applyRange: applyRange)
        })
    }

    
}
