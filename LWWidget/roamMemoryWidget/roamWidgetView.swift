//
//  roamView.swift
//  LWWidgetExtension
//
//  Created by 罗威 on 2022/2/7.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: RoamViewWithPic
struct RoamViewWithPic: View{
    var family:WidgetFamily
    var roamData : RoamData
    var imageData:Data
    var body: some View {
        ZStack(){
            if let image = UIImage(data: imageData){
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 0, maxHeight: .infinity) // 图片撑满背景
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .clipped()
//                    .blur(radius: 2)
                Color.black.opacity(0.6)
            }
            HStack{
                VStack(alignment:.leading){
                    HStack{
                        Text(roamData.date)
                            .multilineTextAlignment(.leading)
                            .font(.custom("DIN Alternate", size: 25))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity,alignment: .leading) // 撑满父视图
                        Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 6)
                                    .foregroundColor(Color.init(hex: 0xE5E5E9))
                            Text(roamData.emojis.joined())
                                .multilineTextAlignment(.trailing)
                                .font(.custom("DIN Alternate", size: 14))
                                .foregroundColor(.black)
                                .padding(2)
                        }
                        .fixedSize()
                    }
                    Text(roamData.content)
                        .multilineTextAlignment(.leading)
                        .font(.custom("DIN Alternate", size: 14))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity,alignment: .leading) // 撑满父视图
                    tagsPanel(tags: roamData.tags)
                }
                .frame(minWidth: 0, maxWidth: .infinity,minHeight: 0, maxHeight: .infinity) // 撑满父视图
            }
            .padding(.horizontal,17)
            .padding(.vertical,family == .systemLarge ? 40 : 20)
        }
    }
}

// MARK: RoamViewWithoutPic
struct RoamViewWithoutPic: View{
    @Environment(\.colorScheme) var colorScheme
    var roamData : RoamData
    var body: some View {
        ZStack{
            cardView()
                .padding(20)
            VStack(alignment:.leading){
                HStack{
                    Text(roamData.date)
                        .multilineTextAlignment(.leading)
                        .font(.custom("DIN Alternate", size: 25))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity,alignment: .leading) // 撑满父视图
                    Spacer()
                    ZStack{
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(colorScheme == .dark ? Color.init(hex: 0x2C2B2E) : Color.init(hex: 0xE5E5E9) )
                        Text(roamData.emojis.joined())
                            .multilineTextAlignment(.trailing)
                            .font(.custom("DIN Alternate", size: 14))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(2)
                    }
                    .fixedSize() // 否则圆角矩形会太大
                }
                Text(roamData.content)
                    .multilineTextAlignment(.leading)
                    .font(.custom("DIN Alternate", size: 14))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity,alignment: .leading) // 撑满父视图
                tagsPanel(tags: roamData.tags)
            }
            .padding(30)
        }
        .frame(minWidth: 0, maxWidth: .infinity,minHeight: 0, maxHeight: .infinity) // 撑满父视图
        
    }
}

// 无图片下小组件的文字背景卡片视图
struct cardView:View{
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .shadow(color: Color.init(hex: 0x9AAACF), radius: 2, x: 0, y: 0)
    }
}

// tags
struct tagsPanel:View{
    var tags:[String]
    var body: some View{
        let filterTags = filterTags(tags: tags)
        HStack(spacing:5){
            ForEach(filterTags) { tag in
                tagView(tag: tag)
            }
        }
    }
}

// tags
struct tagView:View{
    var tag:String
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.init(hex: 0x606163))
            Text("#"+tag)
                .multilineTextAlignment(.trailing)
                .font(.custom("DIN Alternate", size: 10))
                .foregroundColor(.white)
                .padding(3)
        }
        .fixedSize()
    }
}

// 采用了非常简单粗暴的方法解决了tags个数太多导致
func filterTags(tags:[String])->[String]{
    let maxCharacterPerLine = 18
    var n = 0
    var maxTagsNum = 0
    for tag in tags {
        if n + tag.count > maxCharacterPerLine{
            break
        }
        n += (tag.count + 1) // 1:length of '#'
        maxTagsNum += 1
    }
    let subset = tags[0..<maxTagsNum]
    return Array(subset)
}


// MARK: RoamView

struct RoamViewMedium: View {
    var roamData : RoamData
    var body: some View {
        if let imageData = roamData.imageData{
            RoamViewWithPic(family: .systemMedium, roamData: roamData, imageData: imageData)
                .widgetURL(URL.init(string: roamData.date))
        }else{
            RoamViewWithoutPic(roamData: roamData)
                .widgetURL(URL.init(string: roamData.date))
        }
    }
}

struct RoamViewLarge: View {
    var roamData : RoamData
    var body: some View {
        if let imageData = roamData.imageData{
            RoamViewWithPic(family: .systemLarge, roamData: roamData, imageData: imageData)
                .widgetURL(URL.init(string: roamData.date))
        }else{
            RoamViewWithoutPic(roamData: roamData)
                .widgetURL(URL.init(string: roamData.date))
        }
    }
}

//struct RoamWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoamView(roamData: RoamData(date: "test", content: "content",tags: [],emojis: [], imageData: nil))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
