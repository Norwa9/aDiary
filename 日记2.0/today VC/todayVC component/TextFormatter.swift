//
//  TextFormatter.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/11.
//

import Foundation
import UIKit
import JXPhotoBrowser

public class TextFormatter{
    private var textView: UITextView
    private var storage: NSTextStorage
    private var range: NSRange//TextFormatter实例创建时，用户所选取的range
    
    init(textView: UITextView){
        self.textView = textView
        self.range = textView.selectedRange
        self.storage = textView.textStorage
    }
    
    
    
//MARK:-MarkDown：Number List
    //创建数字列表
    func orderedList(){
        //获取当前range所在段落的range
        guard let pRange = getCurParagraphRange() else { return }
        print("pRange:\(pRange)")
        //获取当前段落的所有字符
        let paraMutableString = NSMutableAttributedString(attributedString: textView.attributedText.attributedSubstring(from: pRange))
        let paragraphString = paraMutableString.string
        print("paragraphString:\(paragraphString)")
        
        guard paragraphString != "\n"  else {
            //如果当前段落只有数字或是空段落，那么插入首个序号
            print("insertText(1.)")
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
    
    //自动补齐递增数字列表
    func addNewLine(){
        guard let currentParagraphRange = self.getCurParagraphRange() else { return }
        let currentParagraph = storage.attributedSubstring(from: currentParagraphRange)
        let selectedRange = self.textView.selectedRange
       
        //自动递增数字列表
//        if selectedRange.location != currentParagraphRange.location && selectedRange.location > currentParagraphRange.upperBound - 2{
        if selectedRange.location != currentParagraphRange.location{
            //获取例如4. 这样的前缀
            if let digitsMatch = TextFormatter.getAutocompleteDigitsMatch(string: currentParagraph.string) {
                self.matchDigits(string: currentParagraph, match: digitsMatch)
                return
            }
        }
        print("不自动递增数字列表")
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
    

//MARK:-helper
    //获取当前选取文字所在的段落
    func getCurParagraphRange() -> NSRange? {
        if range.upperBound <= storage.length {
            let paragraphRange = storage.mutableString.paragraphRange(for: range)
            return paragraphRange
        }
        
        return nil
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
        self.textView.textStorage.addAttribute(.paragraphStyle, value: parStyle, range: parRange)
        
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

//MARK:-插入图片
extension TextFormatter{
    func insertPictureToTextView(image:UIImage){
        //创建附件
        let attachment = NSTextAttachment()
        let imageAspectRatio = image.size.height / image.size.width
        let pedding:CGFloat = 15
        let imageWidth = (textView.frame.width - 2 * pedding)
        let imageHeight = (imageWidth * imageAspectRatio)
        let compressedImage = image.compressPic(toSize: CGSize(width: imageWidth * 2, height: imageHeight * 2))//修改尺寸，防止从存储中读取富文本时图片方向错位
        attachment.image = compressedImage.createRoundedRectImage(size: compressedImage.size, radius: compressedImage.size.width / 25)
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: imageWidth / userDefaultManager.imageScalingFactor,
                                   height: imageHeight / userDefaultManager.imageScalingFactor)
        
        //将附件转成NSAttributedString类型的属性化文本
        let imageAttr = NSAttributedString(attachment: attachment)
        let imageAlignmentStyle = NSMutableParagraphStyle()
        imageAlignmentStyle.alignment = .center
        imageAlignmentStyle.lineSpacing = userDefaultManager.lineSpacing
        let attributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle:imageAlignmentStyle,
        ]
        //获取textView的所有文本，转成可变的文本
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        //获得目前光标的位置
        let selectedRange = textView.selectedRange
        //居中插入图片
        let insertLoaction = selectedRange.location
        mutableStr.insert(imageAttr, at: insertLoaction)
        mutableStr.addAttributes(attributes, range: NSRange(location: insertLoaction, length: 1))
        //另起一行
        mutableStr.insert(NSAttributedString(string: "\n"), at: insertLoaction + 1)
        
        mutableStr.addAttribute(NSAttributedString.Key.font, value: userDefaultManager.font, range: NSMakeRange(0,mutableStr.length))
        textView.attributedText = mutableStr
        //从插入图片的下一行继续编辑
        textView.selectedRange = NSRange(location: insertLoaction + 2, length: 0)
        textView.scrollRangeToVisible(textView.selectedRange)
    }
}


//MARK:-点按图片
extension TextFormatter{
    func tappedAttchment(in characterRange:NSRange)->Bool{
        let aString = textView.attributedText!
        let bounds = self.textView.bounds
        let range = characterRange
        let layoutManager = textView.layoutManager
        let container = textView.textContainer
        
        aString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: [], using: { [] (object, range, pointer) in
            let textViewAsAny: Any = textView
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: textViewAsAny as? NSTextContainer, characterIndex: range.location){
                
                let attachmentFrame = layoutManager.boundingRect(forGlyphRange: range, in: container)
                textView.resignFirstResponder()
                
                //图片浏览器数据源
                let browser = JXPhotoBrowser()
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
                    let thumbnailFrame = self.textView.convert(attachmentFrame, to: toView)
                    return (fromView,thumbnailFrame)
                })
                browser.show()
                return
            }
            })
        
        //
        return true
    }
}

//MARK:-保存
extension TextFormatter{
    ///根据日期信息将富文本存储到文件目录
    func save(with diary:diaryInfo){
        savePlainText(with: diary)
        saveRichText(with: diary)
    }
    
    func savePlainText(with diary:diaryInfo){
        guard let date = diary.date else {
            print("savePlainText 失败")
            return
        }
        
        let string = textView.attributedText.processAttrString(textView: self.textView,returnCleanText: true).string
        diary.content = string.replacingOccurrences(of: "P\\b", with: "[图片]",options: .regularExpression)
        
        DataContainerSingleton.sharedDataContainer.diaryDict[date] = diary
        DataContainerSingleton.sharedDataContainer.saveDiaryDict()
    }
    
    
    func saveRichText(with diary:diaryInfo){
        guard let aString = self.textView.attributedText,let date_string = diary.date else{
            print("TextFormatter saveText - 保存失败")
            return
        }
        //1、保存attributedString
        do {
            let file = try aString.fileWrapper (
                from: NSMakeRange(0, aString.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd
                                     ,.characterEncoding:String.Encoding.utf8])
            
            if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
                let path_file_name = dir.appendingPathComponent (date_string)
                do {
                    try file.write (to: path_file_name, options: .atomic, originalContentsURL: nil)
                } catch {
                    // Error handling
                }
            }
        } catch {
            //Error handling
        }
        
        //2、标记保存的日记中是否含有照片
        DataContainerSingleton.sharedDataContainer.diaryDict[date_string]?.containsImage = false
        aString.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: aString.length), options: [], using: { [] (object, range, pointer) in
            if let attachment = object as? NSTextAttachment{
                //如果存在照片
                if let img = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location){
                    DataContainerSingleton.sharedDataContainer.diaryDict[date_string]?.containsImage = true
                    return
                }
            }
        }
        )
    }
}

//MARK:-读取
extension TextFormatter{
    func loadTextViewContent(with diary:diaryInfo){
        textView.textColor = UIColor.black
        self.setLeftTypingAttributes()//内容居左
        let textViewBounds = textView.bounds
        DispatchQueue.global(qos: .default).async {
            if let aString = self.loadAttributedString(date_string: diary.date!){
                //异步读取attributedString、异步处理图片bounds
                let preparedText = aString.processAttrString(bounds: textViewBounds)
                DispatchQueue.main.async {
                    self.textView.attributedText = preparedText
                }
            }else{
                DispatchQueue.main.async {
                    self.textView.text = diary.content//第一次使用app，没有aString可读取，此时将text设置为introduc.txt
                }
            }
        }
    }
    
    ///根据日期string读取从文件目录富文本
    func loadAttributedString(date_string:String) -> NSAttributedString?{
        if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
            let path_file_name = dir.appendingPathComponent (date_string)
            do{
                let aString = try NSAttributedString(
                    url: path_file_name,
                    options: [.documentType:NSAttributedString.DocumentType.rtfd,
                              .characterEncoding:String.Encoding.utf8],
                    documentAttributes: nil)
                return aString
            }catch{
                //
            }
        }
        return nil
    }
    
    ///设置居左的输入模式
    func setLeftTypingAttributes(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
        let typingAttributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle: paragraphStyle,
            .font:userDefaultManager.font
        ]
        self.textView.typingAttributes = typingAttributes
    }
}

//MARK:-placeHolder
extension TextFormatter{
    ///设置textView的Placeholder
    func setPlaceholder(){
        let paraStyle = NSMutableParagraphStyle()
//        paraStyle.alignment = .left
        paraStyle.lineSpacing = userDefaultManager.lineSpacing
        let attributes:[NSAttributedString.Key:Any] = [
            .font:userDefaultManager.font,
            .paragraphStyle : paraStyle,
            .foregroundColor : UIColor.lightGray,
        ]
        let placeHolder = "标题.."
        self.textView.attributedText = NSAttributedString(string: placeHolder, attributes: attributes)
    }
}
