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
    
    var button1:topbarButton!
    var tempButtonImageView1:UIImageView!
    var button2:topbarButton!
    var tempButtonImageView2:UIImageView!
    var button3:topbarButton!
    var tempButtonImageView3:UIImageView!
    var buttonSize:CGSize!
    
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
        dataLable1 = UILabel(frame: CGRect(x: 16, y: 0, width: 195, height: 33))
        dataLable1.font = appDefaultFonts.dateLable1Font
        dataLable1.text = "\(curYear)年\(curMonth)月\(curDay)日"
        dataLable1.sizeToFit()
        self.addSubview(dataLable1)
        //dataLable2
        dataLable2 = UILabel(frame: CGRect(x: 16, y: 25, width: 159, height: 25))
        dataLable2.text = Date().getWeekday()
        dataLable2.font = appDefaultFonts.dateLable2Font
//        dataLable2.text = curWeekDay
        self.addSubview(dataLable2)
        
        let screenRightedgeX = UIScreen.main.bounds.width
        buttonSize = CGSize(width: 40, height: 40)
        //button3
        button3 = topbarButton(frame: CGRect(origin: CGPoint(x: screenRightedgeX - buttonSize.width - 14, y: 3), size: buttonSize))
        button3.image = UIImage(named: "share")
        button3.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button3.tag = 3
        self.addSubview(button3)
        
        //button2
        button2 = topbarButton(frame: CGRect(origin: CGPoint(x: button3.frame.minX - 50, y: 3), size: buttonSize))
        button2.image = UIImage(named: "calm")
        button2.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button2.tag = 2
        self.addSubview(button2)
        
        //button1
        button1 = topbarButton(frame: CGRect(origin: CGPoint(x: button2.frame.minX - 50, y: 3), size: buttonSize))
        button1.image = UIImage(named: "star1")
        button1.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        button1.tag = 1
        self.addSubview(button1)
        
        
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
        
        tempButtonImageView1 = UIImageView(frame: button1.buttonImageView.frame)
        tempButtonImageView1.contentMode = .scaleAspectFill
        tempButtonImageView1.image = UIImage(named: "waterfall")
        tempButtonImageView1.alpha = 0
        button1.addSubview(tempButtonImageView1)
        
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
        
        //
        if currentVCindex == 0{
            //todayVC才能收到通知
            let todayVC = UIApplication.getTodayVC()
            todayVC.todayButtonsTapped(button: sender)
        }else if currentVCindex == 1{
            //monthVC才能收到通知
            let monthVC = UIApplication.getMonthVC()
            monthVC.monthButtonsTapped(button: sender)
        }
        
        
    }
}

//MARK:-当左右滑动切换todayVC和monthVC时，用以下函数来实现topbar的切换动画
extension topbarView{
    func animateDateLabels(currenVCindex:Int,percentComplete:CGFloat){
        //animate labels
        self.dataLable1.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempLabel1.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
        
        self.dataLable2.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempLabel2.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
    }
    
    func animateButtons(currenVCindex:Int,percentComplete:CGFloat){
        //animate buttons
        //切换图标
        self.button1.buttonImageView.alpha = (currenVCindex != 0) ? percentComplete : 1 - percentComplete
        self.tempButtonImageView1.alpha = (currenVCindex != 0) ? 1 - percentComplete : percentComplete
        
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
