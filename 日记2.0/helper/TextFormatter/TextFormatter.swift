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
    
    
    
//MARK:-MarkDown：Number List
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
    
    //MARK:自动补齐todo列表和数字列表
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

                textView.undoManager?.beginUndoGrouping()
                textView.replace(selectedTextRange, withText: checkbox.string)
                textView.textStorage.replaceCharacters(in: NSRange(location: selectedRange.location, length: checkbox.length), with: checkbox)
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
        self.textView.insertText("\n")
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
//MARK:-todo复选框
extension TextFormatter{
    public func insertTodoList(){
        //selectedRange可能覆盖到【多个段落】
        guard let pRange = getCurParagraphRange() else{return}
        
        //为啥叫做为了方便后续的处理，先将名为.todo文本附件替换为占位符"- []"
        let attributedString = textView.attributedText.attributedSubstring(from: pRange)
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
    public func toggleTodo(location:Int,todoAttr:Int) {
        let attributedText = (todoAttr == 0) ? AttributedBox.getChecked() : AttributedBox.getUnChecked()

        self.textView.undoManager?.beginUndoGrouping()
        self.storage.replaceCharacters(in: NSRange(location: location, length: 1), with: (attributedText?.attributedSubstring(from: NSRange(0..<1)))!)
        self.textView.undoManager?.endUndoGrouping()

        guard let paragraph = getParagraphRange(for: location) else { return }
        
        if todoAttr == 0 {
            self.storage.addAttribute(.strikethroughStyle, value: 1, range: paragraph)
            self.storage.addAttribute(.foregroundColor, value: UIColor.systemGray, range: paragraph)
        } else {
            self.storage.removeAttribute(.strikethroughStyle, range: paragraph)
            self.storage.addAttribute(.foregroundColor, value: UIColor.label, range: paragraph)
        }
        
        if paragraph.contains(location) {
            let strike = (todoAttr == 0) ? 1 : 0
            textView.typingAttributes[.strikethroughStyle] = strike
        }
    }
    
}

//MARK:-helper
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

//MARK:-插入图片、时间戳
extension TextFormatter{
    ///插入时间戳
    func insertTimeTag(){
        setLeftTypingAttributes()
        //获取当前时间，格式：-H:mm-
        let formatter = DateFormatter()
        formatter.dateFormat = "-H:mm-"
        let time = formatter.string(from: Date())
        
        textView.insertText(time)
    }
    
    ///插入可变大小图片
    func insertScalableImageView(image:UIImage){
        let location = selectedRange.location
        //插入换行
        textView.textStorage.insert(NSAttributedString(string: "\n"), at: location)
        
        //插入图片
        let defaultViewModel = ScalableImageViewModel(location: location, image: image)
        let view = ScalableImageView(viewModel: defaultViewModel)
        view.delegate = textView
        let subViewAttchment = SubviewTextAttachment(view: view, size: defaultViewModel.bounds.size)
        textView.textStorage.insertAttachment(subViewAttchment, at: location + 1, with: centerParagraphStyle)
        textView.textStorage.addAttribute(.image, value: 1, range: NSRange(location: location + 1, length: 1))//别忘了添加.image key
        
        //插入换行
        textView.textStorage.insert(NSAttributedString(string: "\n"), at: location + 2)
        
        //更新焦点
        textView.selectedRange = NSRange(location: location + 3, length: 0)
        textView.scrollRangeToVisible(textView.selectedRange)
        setLeftTypingAttributes()
    }
}


//MARK:-查看图片
extension TextFormatter{
    func interactAttchment(with characterRange: NSRange,diary:diaryInfo)
    ->NSAttributedString.Key?{
        let bounds = self.textView.bounds
        let range = characterRange
        let layoutManager = textView.layoutManager
        let container = textView.textContainer
        let location = characterRange.location
        
        //1.如果点击的是.todo文本属性
        if let todoAttrValue = storage.attribute(.todo, at: location, effectiveRange: nil) as? Int{
            self.toggleTodo(location: location, todoAttr: todoAttrValue)
            return .todo
        }
        
        
        //2.如果点击的是.image文本属性，提取其attachment
        if let isImage = storage.attribute(.image, at: location, effectiveRange: nil) as? Int,isImage == 1{
            if let imageAttachment = storage.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment, let img = imageAttachment.image(forBounds: bounds, textContainer: container, characterIndex: location){
                
                let attachmentFrame = layoutManager.boundingRect(forGlyphRange: range, in: container)
                textView.resignFirstResponder()
                
                //图片浏览器数据源
                let browser = JXPhotoBrowser()
                //将黑色背景替换为玻璃模糊
                for view in browser.view.subviews{
                    if view.backgroundColor == .black{
                        view.backgroundColor = .clear
                        let effect = UIBlurEffect(style: .dark)
                        let blurView = UIVisualEffectView(effect: effect)
                        view.addSubview(blurView)
                        blurView.snp.makeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                        break
                    }
                }
                
                browser.numberOfItems = { 1 }
                browser.reloadCellAtIndex = { context in
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    browserCell?.imageView.image = img
                }
                
                //显示图片与收回图片的转场动画
                browser.transitionAnimator = JXPhotoBrowserSmoothZoomAnimator(transitionViewAndFrame: { (index, toView) -> JXPhotoBrowserSmoothZoomAnimator.TransitionViewAndFrame? in
                    //toView:大图的imageView
                    //fromView:textView里的图片附件view
                    let fromView = UIImageView(image: img)
                    fromView.contentMode = .scaleAspectFit
                    fromView.clipsToBounds = true
                    //y + 8 是为了解决奇怪的偏移量bug
                    let fromFrame = CGRect(x: attachmentFrame.origin.x, y: attachmentFrame.origin.y + 8, width: attachmentFrame.size.width, height: attachmentFrame.size.height)
                    let thumbnailFrame = self.textView.convert(fromFrame, to: toView)
                    return (fromView,thumbnailFrame)
                })
                browser.show()
                return .image
            }
        }
        
        return nil
    }
}

//MARK:-保存
extension TextFormatter{
    ///根据日期信息将富文本存储到文件目录
    func save(with diary:diaryInfo){
        let attributedText = textView.attributedText!
        let result = attributedText.parseAttribuedText()
        let imageAttrTuples = result.0
        let imageModels = result.7
        let recoveredAttributedText = result.8
        let todoAttrTuples = result.1
        let text = result.2
        let containsImage = result.3
        let incompletedTodos = result.4
        let allTodos = result.6
        
        let plainText = TextFormatter.parsePlainText(text: text,allTodos: allTodos)
        
        //1.保存到本地
        LWRealmManager.shared.update(updateBlock: {
            diary.editedButNotUploaded = true
            diary.modTime = Date()
            diary.content = plainText
            diary.todos = incompletedTodos
            diary.rtfd = recoveredAttributedText.toRTFD()
            diary.containsImage = containsImage
            diary.imageAttributesTuples = imageAttrTuples
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

//MARK:-读取
extension TextFormatter{
    func loadTextViewContent(with diary:diaryInfo){
        self.setLeftTypingAttributes()//内容居左
        let cleanContent = diary.content
        let rtfd = diary.rtfd
        let bounds = textView.bounds
        let container = textView.textContainer
        let imageAttrTuples = diary.imageAttributesTuples
        let imageModels = diary.scalableImageModels
        let todoAttrTuples = diary.todoAttributesTuples
        //print("读取到的images:\(imageAttrTuples)")
        //print("读取到的todos:\(todoAttrTuples)")
        
        DispatchQueue.global(qos: .default).async {
            let attributedText:NSAttributedString = LoadRTFD(rtfd: rtfd) ?? NSAttributedString(string: cleanContent)//rtfd文件非常耗时，后台读取
            //TODO:当用cleanContent替代rtfd时，遍历attribute有可能崩溃
            let correctedAString = self.processAttrString(aString:attributedText,bounds: bounds, container: container, imageAttrTuples: imageAttrTuples, todoAttrTuples: todoAttrTuples,imageModels: imageModels)
            DispatchQueue.main.async {
                self.textView.attributedText = correctedAString
            }
        }
    }
    
    ///读取富文本，并为图片附件设置正确的大小、方向
    ///textViewScreenshot
    ///loadTextViewContent(with:)
    func processAttrString(aString:NSAttributedString, bounds:CGRect, container:NSTextContainer, imageAttrTuples:[(Int,Int)], todoAttrTuples:[(Int,Int)], imageModels:[ScalableImageModel] = [])->NSMutableAttributedString{
        
        let mutableText = NSMutableAttributedString(attributedString: aString)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        //2.恢复.image格式
        for tuple in imageAttrTuples{
            let location = tuple.0//attribute location
            let value = tuple.1//attribute value
            print("恢复image，下标:\(location),aString的长度：\(attrText.length)")
            if let attchment = attrText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment,let image = attchment.image(forBounds: bounds, textContainer: container, characterIndex: location){
                
                if let model = imageModels.filter({$0.location == location}).first{
                    DispatchQueue.main.async {
                        let viewModel = ScalableImageViewModel(model: model,image: image)
                        let view = ScalableImageView(viewModel: viewModel)
                        view.delegate = self.textView
                        let subViewAttchment = SubviewTextAttachment(view: view, size: view.size)
                        attrText.replaceAttchment(subViewAttchment, attchmentAt: viewModel.location, with: viewModel.paraStyle)
                    }
                }else{
                    print("\(location)对应的图片model没有找到！提供默认viewModel")
                    DispatchQueue.main.async {
                        let defaultViewModel = ScalableImageViewModel(location: location, image: image)
                        let view = ScalableImageView(viewModel: defaultViewModel)
                        view.delegate = self.textView
                        let subViewAttchment = SubviewTextAttachment(view: view, size: view.size)
                        attrText.replaceAttchment(subViewAttchment, attchmentAt: defaultViewModel.location, with: defaultViewModel.paraStyle)
                    }
                }
                
                //重新添加.image属性（用于保存时检索图片attchment）
                attrText.addAttribute(.image, value: value, range: NSRange(location: location, length: 1))
            }
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
        let bounds = textView.bounds
        let container = textView.textContainer
        let imageAttrTuples = diary.imageAttributesTuples
        let todoAttrTuples = diary.todoAttributesTuples
        let attributedText = textView.attributedText ?? NSAttributedString(string: "")
        let correctedAString = self.processAttrString(aString:attributedText,bounds: bounds, container: container, imageAttrTuples: imageAttrTuples, todoAttrTuples: todoAttrTuples)
        self.textView.attributedText = correctedAString
    }
    
}

//MARK:-helper
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
    
    ///设置居左的输入模式
    func setLeftTypingAttributes(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
        let typingAttributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle: paragraphStyle,
            .font:userDefaultManager.font,
            .foregroundColor : UIColor.label
        ]
        self.textView.typingAttributes = typingAttributes
    }
}

//MARK:-分享
extension TextFormatter{
    func textViewScreenshot(diary:diaryInfo) -> UIImage{
        let attributedText = diary.attributedString
        //异步读取attributedString、异步处理图片bounds
        let bounds = textView.bounds
        let container = textView.textContainer
        let imageAttrTuples = diary.imageAttributesTuples
        let todoAttrTuples = diary.todoAttributesTuples
        
        let preparedText = self.processAttrString(aString:attributedText,bounds: bounds, container: container, imageAttrTuples: imageAttrTuples, todoAttrTuples: todoAttrTuples)
        
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
        let attrText = self.textView.attributedText.addUserDefaultAttributes()
        self.textView.attributedText = attrText
        return attrText
    }
    
}

