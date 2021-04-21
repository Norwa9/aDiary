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
    
    func exportAll(completion: @escaping() -> Void){
        let todayVC = UIApplication.getTodayVC()
        guard let textView = todayVC.textView else{return}
        let textViewBounds = textView.bounds
        let textContainer = textView.textContainer
        
        DispatchQueue.global(qos: .default).async{
            let diaryDict = DataContainerSingleton.sharedDataContainer.diaryDict
            let dateFomatter = DateFormatter()
            dateFomatter.dateFormat = "yyyy年M月d日"
            let orderedDates = diaryDict.keys.sorted(){ (d1, d2) -> Bool in
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
                .font : UIFont(name: userDefaultManager.fontName, size: userDefaultManager.fontSize)!,
                .foregroundColor : APP_GREEN_COLOR()
            ]
            for date in orderedDates{
                if let aString = loadAttributedString(date_string: date),aString.length != 0{
                    let dateTitle = NSAttributedString(string: date, attributes: titleAttributes)
                    alldiaryString.append(dateTitle)
                    alldiaryString.insert(NSAttributedString(string: "\n"), at: alldiaryString.length)
                    let formatteredaString = aString.processAttrString(textViewbouds: textViewBounds, textContainer: textContainer)//规范图片大小和字体格式
                    alldiaryString.append(formatteredaString)
                    alldiaryString.insert(NSAttributedString(string: "\n"), at: alldiaryString.length)
                    
                }
            }
            
            //打印pdf参考：https://stackoverflow.com/questions/56849245/swift-save-uitextview-text-to-pdf-doc-and-txt-file-formate-and-display
            let aString = alldiaryString
            let filename = "导出日记"
            //主线程打印pdf。
            //通过排查下面的一些代码必须在主线程运行，但是不明白其中的道理。。
            DispatchQueue.main.async {
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

                for i in 1...render.numberOfPages {
                    UIGraphicsBeginPDFPage();
                    let bounds = UIGraphicsGetPDFContextBounds()
                    render.drawPage(at: i - 1, in: bounds)
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
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                UIApplication.getTopViewController()!.present(activityVC, animated: true, completion: nil)
            }//main thread
            
        }//backgournd thread
        
    }
    
    

}
