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
    var curWeekDay:String = "Mon"
    
    var dataLable1:UILabel!
    var dataLable2:UILabel!
    var tempLabel1:UILabel!
    var tempLabel2:UILabel!
    var rectBar1:UIView!
    
    var button1:topbarButton!
    var button2:topbarButton!
    var tempButtonImageView2:UIImageView!
    var button3:topbarButton!
    var tempButtonImageView3:UIImageView!
    var buttonSize:CGSize!
    var rectBar2:UIView!
    
    var topbarButtons:[topbarButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTodayTopBarUI()
        setupMonthTopBarUI()
        setupUIconstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTodayTopBarUI(){
        //get current date
        let timeNow = Date()
        timeFormatter.dateFormat = "yyyy"
        curYear = Int(timeFormatter.string(from: timeNow))!
        timeFormatter.dateFormat = "MM"
        curMonth = Int(timeFormatter.string(from: timeNow))!
        timeFormatter.dateFormat = "dd"
        curDay = Int(timeFormatter.string(from: timeNow))!
        
        //datalabe1
        dataLable1 = UILabel(frame: CGRect(x: 16, y: 49, width: 195, height: 33))
        dataLable1.font = appDefaultFonts.dateLable1Font
        dataLable1.text = "\(curYear)年\(curMonth)月\(curDay)日"
        dataLable1.sizeToFit()
        self.addSubview(dataLable1)
        //dataLable2
        dataLable2 = UILabel(frame: CGRect(x: 16, y: 76, width: 159, height: 25))
        dataLable2.text = getWeekDayFromDateString(string: dataLable1.text!)
        dataLable2.font = appDefaultFonts.dateLable2Font
//        dataLable2.text = curWeekDay
        self.addSubview(dataLable2)
        //rectbar1
        rectBar1 = UIView(frame: CGRect(x: 14, y: 44, width: dataLable1.frame.size.width, height: 5))
        rectBar1.backgroundColor = .white
        rectBar1.layer.cornerRadius = 2
        rectBar1.setupShadow(opacity: 0.35, radius: 1, offset: CGSize(width: 1, height: 1), color: .black)
        self.addSubview(rectBar1)
        
        buttonSize = CGSize(width: 40, height: 40)
        //button1
        button1 = topbarButton(frame: CGRect(origin: CGPoint(x: 255, y: 52), size: buttonSize))
        button1.image = UIImage(named: "star1")
        button1.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button1.tag = 1
        self.addSubview(button1)
        //button2
        button2 = topbarButton(frame: CGRect(origin: CGPoint(x: button1.frame.minX + 50, y: 52), size: buttonSize))
        button2.image = UIImage(named: "calm")
        button2.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button2.tag = 2
        self.addSubview(button2)
        //button3
        button3 = topbarButton(frame: CGRect(origin: CGPoint(x: button2.frame.minX + 50, y: 52), size: buttonSize))
        button3.image = UIImage(named: "tag")
        button3.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button3.tag = 3
        self.addSubview(button3)
        //rectbar2
        rectBar2 = UIView(frame: CGRect(x: button1.frame.minX, y: 44, width: button3.frame.maxX-button1.frame.minX, height: 5))
        rectBar2.backgroundColor = .white
        rectBar2.layer.cornerRadius = 2
        rectBar2.setupShadow(opacity: 0.35, radius: 1, offset: CGSize(width: 1, height: 1), color: .black)
        self.addSubview(rectBar2)
        
        
        rectBar1.isHidden = true
        rectBar2.isHidden = true
        
        topbarButtons = [button1,button2,button3]
    }
    
    func setupUIconstraint(){

    }
    
    func setupMonthTopBarUI(){
        tempLabel1 = UILabel(frame: dataLable1.frame)
        tempLabel1.text = "\(curYear)年"
        tempLabel1.sizeToFit()
        tempLabel1.font = dataLable1.font
        tempLabel1.textAlignment = dataLable1.textAlignment
        tempLabel1.textColor = dataLable1.textColor
        tempLabel1.alpha = 0
        self.addSubview(tempLabel1)
        
        tempLabel2 = UILabel(frame: dataLable2.frame)
        tempLabel2.text = "\(curMonth)月"
        tempLabel2.sizeToFit()
        tempLabel2.font = dataLable2.font
        tempLabel2.textAlignment = dataLable2.textAlignment
        tempLabel2.textColor = dataLable1.textColor
        tempLabel2.alpha = 0
        self.addSubview(tempLabel2)
        
        tempButtonImageView2 = UIImageView(frame: button2.buttonImageView.frame)
        tempButtonImageView2.contentMode = .scaleAspectFill
        tempButtonImageView2.image = UIImage(named: "setting")
        tempButtonImageView2.alpha = 0
        button2.addSubview(tempButtonImageView2)
        
        tempButtonImageView3 = UIImageView(frame: button3.buttonImageView.frame)
        tempButtonImageView3.contentMode = .scaleAspectFill
        tempButtonImageView3.image = UIImage(named: "search")?.withHorizontallyFlippedOrientation()
        tempButtonImageView3.alpha = 0
        tempButtonImageView3.tag = 99
        button3.addSubview(tempButtonImageView3)
        
    }
    
    @objc func tapped(sender:topbarButton){
        //animation
        sender.bounceAnimation(usingSpringWithDamping: 0.5)
        print("topbar view currentVCindex:\(currentVCindex)")
        let notificationCenter = NotificationCenter.default
        if currentVCindex == 0{
            //todayVC才能收到通知
            notificationCenter.post(name: Notification.Name("todayButtonsTapped"), object: nil, userInfo: ["buttonTag":sender])
        }else if currentVCindex == 1{
            //monthVC才能收到通知
            notificationCenter.post(name: Notification.Name("monthButtonsTapped"), object: nil, userInfo: ["buttonTag":sender])
        }
        
        
    }
}

//MARK:-当左右滑动切换todayVC和monthVC时，用以下函数来实现topbar的切换动画
extension topbarView{
    func animateBars(currenVCindex:Int,percentComplete:CGFloat){
        //animate rect bars
        let tempLabel1Width = self.tempLabel1.frame.size.width
        let dateLabel1Width = self.dataLable1.frame.size.width
        self.rectBar1.frame.size.width = (currenVCindex != 0) ?
            tempLabel1Width + (dateLabel1Width - tempLabel1Width) * (percentComplete) :
            tempLabel1Width + (dateLabel1Width - tempLabel1Width) * (1.0 - percentComplete)
        
        self.rectBar2.frame.origin.x = (currenVCindex != 0) ?
            self.button3.frame.minX - (self.button3.frame.minX - self.button1.frame.minX) * (percentComplete) :
            self.button1.frame.minX + (self.button3.frame.minX - self.button1.frame.minX) * (percentComplete)
        self.rectBar2.frame.size.width = (currenVCindex != 0) ?
            (self.button3.frame.maxX - self.button3.frame.minX) + (self.button3.frame.minX - self.button1.frame.minX) * (percentComplete) :
            (self.button3.frame.maxX - self.button1.frame.minX) - (self.button3.frame.minX - self.button1.frame.minX) * (percentComplete)
    }
    
    func animateDateLabels(currenVCindex:Int,percentComplete:CGFloat){
        //animate labels
        self.dataLable1.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempLabel1.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
        
        self.dataLable2.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempLabel2.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
    }
    
    func animateButtons(currenVCindex:Int,percentComplete:CGFloat){
        //animate buttons
        //button1消失
        self.button1.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        //button2和button3切换图标
        self.button2.buttonImageView.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempButtonImageView2.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
        
        self.button3.buttonImageView.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempButtonImageView3.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
    }
}

extension topbarView{
    func changeButtonImageView(topbarButtonIndex buttonIndex:Int,toImage:UIImage){
        self.topbarButtons[buttonIndex].buttonImageView.image = toImage
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: []) {
            self.topbarButtons[buttonIndex].buttonImageView.transform  = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.topbarButtons[buttonIndex].buttonImageView.transform  = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { (_) in}
        
        
    }
}
