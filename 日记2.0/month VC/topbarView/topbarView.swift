//
//  topbarView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

class topbarView: UIView {
    var currentVCindex:Int = 0
    //get current date
    let timeFormatter = DateFormatter()
    var curYear:Int = 0
    var curMonth:Int = 0
    var curDay:Int = 0
    
    var dataLable1:UILabel!
    var dataLable2:UILabel!
    var backwordBtn:UIButton!
    var forwardBtn:UIButton!
    var button0:topbarButton!//日历
    var button1:topbarButton!
    var button2:topbarButton!
    var button3:topbarButton!
    
    
    var topbarButtons:[topbarButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupUIconstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.backgroundColor = LWColorConstatnsManager.LWSoftBGColor
        
        //get current date
        let timeNow = Date()
        timeFormatter.dateFormat = "yyyy"
        curYear = Int(timeFormatter.string(from: timeNow))!
        timeFormatter.dateFormat = "MM"
        curMonth = Int(timeFormatter.string(from: timeNow))!
        timeFormatter.dateFormat = "dd"
        curDay = Int(timeFormatter.string(from: timeNow))!
        
        //datalabe1
        dataLable1 = UILabel()
        dataLable1.font = appDefault.dateLable1Font
        dataLable1.text = "\(curYear)年"
        dataLable1.sizeToFit()
        dataLable1.textColor = .label
        self.addSubview(dataLable1)
        
        //backward button
        backwordBtn = UIButton()
        backwordBtn.setImage(UIImage(named: "chevron.backward.circle"), for: .normal)
        backwordBtn.tag = 0
        backwordBtn.addTarget(self, action: #selector(yearChangeAction(_:)), for: .touchUpInside)
        self.addSubview(backwordBtn)
        
        //forward button
        forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "chevron.forward.circle"), for: .normal)
        forwardBtn.tag = 1
        forwardBtn.addTarget(self, action: #selector(yearChangeAction(_:)), for: .touchUpInside)
        self.addSubview(forwardBtn)
        
        //dataLable2
        dataLable2 = UILabel()
        dataLable2.text = "\(curMonth)月"
        dataLable2.font = appDefault.dateLable2Font
        dataLable2.textColor = .label
        self.addSubview(dataLable2)
        
        
        
        //button3：搜索
        button3 = topbarButton()
        button3.image = UIImage(named: "search")
        button3.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button3.tag = 3
        self.addSubview(button3)
        
        //button2：设置
        button2 = topbarButton()
        button2.image = UIImage(named: "setting")
        button2.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button2.tag = 2
        self.addSubview(button2)
        
        //button1：布局样式
        button1 = topbarButton()
        var layoutTypeImg:UIImage
        switch layoutParasManager.shared.collectioncolumnNumber {
        case 1:
            layoutTypeImg = UIImage(named: "waterfallmode")!
        default:
            layoutTypeImg = UIImage(named: "listmode")!
        }
        button1.image = layoutTypeImg
        button1.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button1.tag = 1
        self.addSubview(button1)
        
        //button0：日历
        button0 = topbarButton()
        button0.image = UIImage(named: "calendar")
        button0.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button0.tag = 0
        self.addSubview(button0)
        
        
        topbarButtons = [button0,button1,button2,button3]
    }
    
    func setupUIconstraint(){
        backwordBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(dataLable1)
            make.left.equalToSuperview().inset(10)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        dataLable1.snp.makeConstraints { make in
            make.left.equalTo(backwordBtn.snp.right).offset(1)
            make.top.equalToSuperview()
            make.height.equalTo(25)
        }
        
        forwardBtn.snp.makeConstraints { (make) in
            make.left.equalTo(dataLable1.snp.right).offset(1)
            make.centerY.equalTo(backwordBtn)
            make.size.equalTo(backwordBtn)
        }
        
        dataLable2.snp.makeConstraints { make in
            make.left.equalTo(dataLable1)
            make.top.equalTo(dataLable1.snp.bottom)
            make.size.equalTo(CGSize(width: 159, height: 25))
        }
        
        let buttonSize = CGSize(width: 40 * globalConstantsManager.shared.zoomModelScale, height: 40 * globalConstantsManager.shared.zoomModelScale)
        print("top bar button size : \(40 * globalConstantsManager.shared.zoomModelScale)")
        
        button3.snp.makeConstraints { make in
            make.top.equalTo(dataLable1)
            make.right.equalTo(self.snp.right).inset(16)
            make.size.equalTo(buttonSize)
        }
        
        button2.snp.makeConstraints { make in
            make.top.equalTo(button3)
            make.right.equalTo(button3.snp.left).inset(-10)
            make.size.equalTo(buttonSize)
        }
        
        button1.snp.makeConstraints { make in
            make.top.equalTo(button2)
            make.right.equalTo(button2.snp.left).inset(-10)
            make.size.equalTo(buttonSize)
        }
        
        button0.snp.makeConstraints { make in
            make.top.equalTo(button1)
            make.right.equalTo(button1.snp.left).inset(-10)
            make.size.equalTo(buttonSize)
        }
    }
    
    
}

//MARK:-target action
extension topbarView{
    @objc func tapped(sender:topbarButton){
        //animation
        sender.bounceAnimation(usingSpringWithDamping: 0.8)
        
        let monthVC = UIApplication.getMonthVC()
        monthVC?.topToolButtonTapped(button: sender)
    }
    
    @objc func yearChangeAction(_ sender:UIButton){
        let monthVC = UIApplication.getMonthVC()
        if sender.tag == 0{
            monthVC?.selectedYear -= 1
        }else{
            monthVC?.selectedYear += 1
        }
        monthVC?.updateUI()
    }
}
