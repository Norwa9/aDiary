//
//  attribuedStringStorage.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/23.
//

import Foundation
import UIKit
//MARK:-根据日期信息将富文本存储到文件目录
func saveAttributedString(date_string:String,aString:NSAttributedString?) {
    do {
        let file = try aString?.fileWrapper (
            from: NSMakeRange(0, aString!.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
        
        if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
            let path_file_name = dir.appendingPathComponent (date_string)
            do {
                try file!.write (to: path_file_name, options: .atomic, originalContentsURL: nil)
            } catch {
                // Error handling
            }
        }
    } catch {
        //Error handling
    }
    
}

//MARK:-根据日期信息读取从文件目录富文本
func loadAttributedString(date_string:String) -> NSAttributedString?{
    if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
        let path_file_name = dir.appendingPathComponent (date_string)
        do{
            let aString = try NSAttributedString(
                url: path_file_name,
                options: [.documentType:NSAttributedString.DocumentType.rtfd],
                documentAttributes: nil)
//            print("load \(date_string) attributedString")
            return aString
        }catch{
            //
        }
    }
    return nil
}



