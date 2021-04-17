//
//  fileManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/16.
//

import Foundation
import UIKit

class customFileManager{
    //查看文件夹下的文件
    static func list(Folder:String?) -> [String]{
        if let path = Folder{
            if let list = try? FileManager.default.contentsOfDirectory(atPath: path){
                return list
            }
        }
        return ["空的"]
    }
    
    func del(Folder:String,fileName:String) -> Bool{
        let path = (Folder as NSString).appendingPathComponent(fileName)
        var error: NSError?
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error1 as NSError {
            error = error1
        }
        return error == nil
    }
    
    static func delallPDF(inFolder:String?){
        if let path = inFolder{
            if let list = try? FileManager.default.contentsOfDirectory(atPath: path){
                for filepath in list{
                    if filepath.hasSuffix(".pdf"){
                        try? FileManager.default.removeItem(atPath: filepath)
                        print("\(filepath)已删除")
                    }
                }
            }
        }
    }
}
