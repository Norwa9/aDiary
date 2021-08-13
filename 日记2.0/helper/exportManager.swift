//
//  exportManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/16.
//

import Foundation
import UIKit
class exportManager{
    
    static let shared = exportManager()
    
    ///导出PDF
    func exportAll(completion: @escaping() -> Void){
        let W = min(globalConstantsManager.shared.kScreenWidth, globalConstantsManager.shared.kScreenHeight)
        let H = max(globalConstantsManager.shared.kScreenWidth, globalConstantsManager.shared.kScreenHeight)
        indicatorViewManager.shared.start(type: .progress)
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: W, height: H))
        let textViewBounds = textView.bounds
        let textContainer = textView.textContainer
        let formatter = TextFormatter(textView: textView)
        
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy年M月d日"
        //print("000000000")
        DispatchQueue.global(qos: .default).async{
            let allDiary = LWRealmManager.queryAllDieryOnCurrentThread()
            let sortedAllDiary = allDiary.sorted { (m1, m2) -> Bool in
                let d1 = m1.date
                let d2 = m2.date
                if let date1 = dateFomatter.date(from: d1) ,let date2 = dateFomatter.date(from: d2){
                    if date1.compare(date2) ==  .orderedAscending{
                        return true
                    }
                }
                return false
            }
            
            //1.merge all diaries into one
            let alldiaryString = NSMutableAttributedString()

            //date title
            let titlePara = NSMutableParagraphStyle()
            titlePara.alignment = .left
            titlePara.lineSpacing = userDefaultManager.lineSpacing
            let titleAttributes : [NSAttributedString.Key:Any] = [
                .paragraphStyle : titlePara,
                .font : userDefaultManager.font,
                .foregroundColor : APP_GREEN_COLOR()
            ]
            for diary in sortedAllDiary{
                if let rtfd = diary.rtfd,let aString = LoadRTFD(rtfd: rtfd),aString.length != 0{
                    //日期
                    let date = diary.date
                    let dateTitle = NSAttributedString(string: date, attributes: titleAttributes)
                    alldiaryString.append(dateTitle)
                    alldiaryString.insert(NSAttributedString(string: "\n"), at: alldiaryString.length)
                    
                    //正文
                    let imageAttrTuples = diary.imageAttributesTuples
                    let todoAttrTuples = diary.todoAttributesTuples
                    let formatteredAString = formatter.processAttrString(aString: aString, bounds: textViewBounds, container: textContainer, imageAttrTuples: imageAttrTuples, todoAttrTuples: todoAttrTuples)
                    
                    //添加一篇
                    alldiaryString.append(formatteredAString)
                    alldiaryString.insert(NSAttributedString(string: "\n"), at: alldiaryString.length)

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

                completion()
                indicatorViewManager.shared.stop()
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
    
    

}
