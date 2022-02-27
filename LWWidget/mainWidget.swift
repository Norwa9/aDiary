//
//  mainWidget.swift
//  LWWidgetExtension
//
//  Created by 罗威 on 2022/2/7.
//

import Foundation
import SwiftUI
import Intents



//MARK:-Widget 的主入口函数
///入口：Widget 的主入口函数，可以设置Widget的标题和说明，规定其显示的View、Provider、支持的尺寸等信息。
@main
struct Widgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget{
        RoamWidget()
        TodoWidget()
    }
}
