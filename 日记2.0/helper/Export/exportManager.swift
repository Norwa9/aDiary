//
//  exportManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/16.
//

import Foundation
import UIKit
class exportManager{
    var completion: (() -> Void)?
    let pageW = 595.2 - 50 * 2
    let pageH = 841.8 - 50 * 2
    
    static let shared = exportManager()
    
    //MARK: 导出PDF
    
    func exportPDF(startDate:Date,endDate:Date){
        indicatorViewManager.shared.start(type: .progress)
        
        let W = min(globalConstantsManager.shared.kScreenWidth, globalConstantsManager.shared.kScreenHeight)
        let H = max(globalConstantsManager.shared.kScreenWidth, globalConstantsManager.shared.kScreenHeight)
        let textView = LWTextView(frame: CGRect(x: 0, y: 0, width: W, height: H))
        let formatter = TextFormatter(textView: textView)
        
        DispatchQueue.main.async{
            let sortedAllDiary = self.getFilteredDiary(startDate: startDate, endDate: endDate)
            
            //1.merge all diaries into one
            let alldiaryString = NSMutableAttributedString()

            //date title
            let titlePara = NSMutableParagraphStyle()
            titlePara.alignment = .left
            titlePara.lineSpacing = userDefaultManager.lineSpacing
            let titleAttributes : [NSAttributedString.Key:Any] = [
                .paragraphStyle : titlePara,
                .font : userDefaultManager.font.bold() ?? userDefaultManager.font,
            ]
            var lastTrueDate:String? = nil
            for diary in sortedAllDiary{
                if let rtfd = diary.rtfd,let aString = LoadRTFD(rtfd: rtfd),aString.length != 0{
                    let onePage = NSMutableAttributedString(string: "")
                    
                    // 1.日期
                    let date = diary.date
                    let dateTitle = NSAttributedString(string: date, attributes: titleAttributes)
                    onePage.append(dateTitle)
                    onePage.insert(NSAttributedString(string: "\n"), at: onePage.length)
                    // 2. 正文
                    let imageModels = diary.scalableImageModels
                    let todoModels = diary.lwTodoModels
                    let soundModels = diary.lwSoundModels
                    let contentAttributedString = formatter.processAttrString(
                        aString: aString,
                        todoModels: todoModels,
                        imageModels: imageModels,
                        soundModels: soundModels,
                        isSharingMode: true,
                        isExportMode: true
                    )
                    // 3. emojis
                    var emojis = diary.emojis.joined()
                    if emojis.length != 0{
                        emojis += "\n"
                    }
                    onePage.insert(NSAttributedString(string: emojis), at: onePage.length)
                    onePage.insert(contentAttributedString, at: onePage.length)
                    
                    //添加一篇(同一天内的不同的日记间隔小)
                    if let lastTrueDate = lastTrueDate{
                        if lastTrueDate == diary.trueDate{
                            alldiaryString.insert(NSAttributedString(string: "\n\n"), at: alldiaryString.length)
                        }else{
                            alldiaryString.insert(NSAttributedString(string: "\n\n\n\n\n\n\n\n"), at: alldiaryString.length)
                        }
                    }else{
                        // 第一篇不处理
                    }
                    alldiaryString.append(onePage)
                    
                    lastTrueDate = diary.trueDate // 更新lastTrueDate
                }
            }

            //打印pdf参考：https://stackoverflow.com/questions/56849245/swift-save-uitextview-text-to-pdf-doc-and-txt-file-formate-and-display
            let aString = alldiaryString
            let filename = "aDiary日记导出PDF-\(GetTodayDate())"
            //print("1111111111")
            //主线程打印pdf。
            //通过排查下面的一些代码必须在主线程运行，但是不明白其中的道理。。
            DispatchQueue.main.async {
                //print("2222222222")
                // 1. Create Print Formatter with input text.
                //必须置于主线程
                //--
                let formatter = UISimpleTextPrintFormatter(attributedText: aString)//选取打印机
                // 2. Add formatter with pageRender
                let render = UIPrintPageRenderer()
                render.addPrintFormatter(formatter, startingAtPageAt: 0)
                //--

                // 3. Assign paperRect and printableRect
                let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
                let printable = page.insetBy(dx: 50, dy: 50)

                render.setValue(NSValue(cgRect: page), forKey: "paperRect")
                render.setValue(NSValue(cgRect: printable), forKey: "printableRect")

                // 4. Create PDF context and draw
                let rect = CGRect.zero

                let pdfData = NSMutableData()

                //必须置于主线程，不知道为什么
                //--
                UIGraphicsBeginPDFContextToData(pdfData, rect, nil)
                let pagesNun = render.numberOfPages
                for i in 1...pagesNun {
                    let progress:Float = Float(i) / Float(pagesNun)
                    //indicatorViewManager.shared.progress = progress
                    UIGraphicsBeginPDFPage();
                    let bounds = UIGraphicsGetPDFContextBounds()
                    render.drawPage(at: i - 1, in: bounds)
                    indicatorViewManager.shared.progress = progress
                    print("PDF导出进度:\(progress * 100)%")
                }
                UIGraphicsEndPDFContext();
                //--

                // 5. Save PDF file
                //获取临时文件夹目录，临时文件夹内的文件会在app重启后删除
//                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let tempDocumentsPath = NSTemporaryDirectory()
                //必须置于主线程，不知道为什么
                //--
                pdfData.write(toFile: "\(tempDocumentsPath)/\(filename).pdf", atomically: true)
                //--


                //6. share
                let filePath = (tempDocumentsPath as NSString).appendingPathComponent("\(filename).pdf")
                let url = URL(fileURLWithPath: filePath)

                indicatorViewManager.shared.stop()
                self.completion?()
                // 分享
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                let topVC = UIApplication.getTopViewController()!
                //ipad上要挂载到某个view上
                let isPad = ( UIDevice.current.userInterfaceIdiom == .pad)
                if isPad {
                    activityVC.popoverPresentationController?.sourceView = topVC.view
                    activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.width / 2, y: topVC.view.bounds.height / 2, width: 0, height: 0)
                    activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
                }
                
                topVC.present(activityVC, animated: true, completion: nil)
            }//main thread

        }//backgournd thread
        
    }
    
    /// adaptScale:插图占屏幕的百分比
    func getImageAdaptatedSize(size:CGSize,adaptScale:CGFloat)->CGSize{
        let imageRatio = size.height / size.width
        var imageAdaptatedWidth = self.pageW * adaptScale // 适应到A4值上，图片的相对宽度
        if imageAdaptatedWidth > self.pageW / 2{
            // 缩放图片，防止图片太宽文字与图片比例失调
            imageAdaptatedWidth = self.pageW / 2
        }
        var imageAdaptatedHeight = imageRatio * imageAdaptatedWidth
        if imageAdaptatedHeight > self.pageH / 2{
            // 继续放缩，防止图片太长造成裁剪
            imageAdaptatedHeight = self.pageH / 2
            imageAdaptatedWidth = imageAdaptatedHeight / imageRatio
        }
        return CGSize(width: imageAdaptatedWidth, height: imageAdaptatedHeight)
    }
    
    func getTodoAdaptatedSize(size:CGSize)->CGSize{
        let scale = size.height / size.width
        let newWidth = self.pageW * 0.95 // 0.95是默认todo宽度与屏幕宽度的比值
        let newHeight = newWidth * scale
        return CGSize(width: newWidth, height: newHeight)
        
    }
    
    func getSoundAdaptatedSize(size:CGSize)->CGSize{
        let scale = size.height / size.width
        let newWidth = self.pageW * 0.95 // 0.95是默认todo宽度与屏幕宽度的比值
        let newHeight = newWidth * scale
        return CGSize(width: newWidth, height: newHeight)
    }
    
    //MARK: text
    func exportText(startDate:Date,endDate:Date){
        indicatorViewManager.shared.start(type: .progress)
        let allDiary = getFilteredDiary(startDate: startDate, endDate: endDate)
        var text = ""
        var lastTrueDate:String? = nil
        for (i,diary) in allDiary.enumerated(){
            let progress:Float = Float(i) / Float(allDiary.count)
            indicatorViewManager.shared.progress = progress
            
            //1
            let date = diary.date
            //2
            let emojis = " " + diary.emojis.joined() + "\n"
            //3
            let content = diary.content
            
            let oneDiary = date + emojis + content
            
            if let lastTrueDate = lastTrueDate{
                if lastTrueDate == diary.trueDate{
                    text.append("\n\n")
                }else{
                    text.append("\n\n\n\n")
                }
            }else{
                // 第一篇不处理
            }
            text += oneDiary
            lastTrueDate = diary.trueDate
        }
        indicatorViewManager.shared.stop()
        completion?()
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        guard let topVC = UIApplication.getTopViewController() else{return}
        //ipad上要挂载到某个view上
        let isPad = ( UIDevice.current.userInterfaceIdiom == .pad)
        if isPad {
            activityVC.popoverPresentationController?.sourceView = topVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.width / 2, y: topVC.view.bounds.height / 2, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        }
        topVC.present(activityVC, animated: true, completion: nil)
        
    }
    
    
    /// 返回在日期区间内，顺序的日记
    private func getFilteredDiary(startDate:Date,endDate:Date) -> [diaryInfo]{
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy年M月d日"
        let allDiary = LWRealmManager.queryAllDieryOnCurrentThread()
        // 获取日期区间内日记（过滤区间外、模板）
        let filteredDiary = allDiary.filter { diary in
            let dateCN = diary.trueDate
            if let date = dateFomatter.date(from: dateCN){
                if (date.compare(startDate) == .orderedDescending || date.compare(startDate) == .orderedSame)
                    &&
                    (date.compare(endDate) == .orderedAscending || date.compare(endDate) == .orderedSame)
                {
                    return true
                }
            }
            return false
        }
        let sortedAllDiary = filteredDiary.sorted { (m1, m2) -> Bool in
            let d1 = m1.trueDate
            let d2 = m2.trueDate
            if let date1 = dateFomatter.date(from: d1) ,let date2 = dateFomatter.date(from: d2){
                //如果日期不一样，日期早的排在前
                if date1.compare(date2) ==  .orderedAscending{
                    return true
                }
                //如果日期一样，页面号小的排在前
                if date1.compare(date2) == .orderedSame{
                    let pageIndex1 = m1.indexOfPage
                    let pageIndex2 = m2.indexOfPage
                    return pageIndex1 < pageIndex2
                }
            }
            return false
        }
        
        return sortedAllDiary
    }
    

}
