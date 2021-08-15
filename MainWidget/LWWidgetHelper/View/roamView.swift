//
//  roamView.swift
//  日记2.0
//
//  Created by yy on 2021/8/13.
//

import Foundation
import SwiftUI

struct RoamView: View {
    var roamData : RoamData
    var body: some View {
        VStack{
            Text(roamData.date)
                .multilineTextAlignment(.leading)
                .font(.custom("DIN Alternate", size: 18))
            Text(roamData.content)
                .multilineTextAlignment(.leading)
                .font(.custom("DIN Alternate", size: 15))
                .padding(.all)
                .widgetURL(URL(string: "\(roamData.date)"))
        }
    }
}

