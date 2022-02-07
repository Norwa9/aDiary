//
//  roamView.swift
//  LWWidgetExtension
//
//  Created by 罗威 on 2022/2/7.
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
