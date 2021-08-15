//
//  roamView.swift
//  日记2.0
//
//  Created by yy on 2021/8/13.
//

import Foundation
import SwiftUI

struct RoamView: View {
    var content:String = "随机查看一篇日记"
    var body: some View {
        Text(content)
            .multilineTextAlignment(.center)
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct RoamView_Previews: PreviewProvider {
    static var previews: some View {
        RoamView(content: "PlaceHolder")
    }
}
