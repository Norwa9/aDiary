//
//  Data+.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/26.
//

import Foundation

extension Data{
    func printSize(){
        print("rtfd大小： \(self.count) bytes")
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self.count))
        print("rtfd大小（换算成MB）: \(string)")
    }
}
