//
//  customAlertView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/13.
//

import UIKit
class customAlertView: UIView {
    let title = UILabel()
    let cancelButton = UIButton()
    let createDiaryButton = UIButton()
    let monthVC = UIApplication.getMonthVC()
    var dateString:String?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancel), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        //标题
        title.frame = CGRect(x: 0, y: 12, width: 150, height: 24)
        title.textAlignment = .center
        title.font = UIFont.init(name: "DIN Alternate", size: 20)
        title.text = "无日记"
        self.addSubview(title)
        
        //创建按钮
        createDiaryButton.frame = CGRect(x: 104, y: 44, width: 30, height: 30)
        let createDiaryButtonAttributes:[NSAttributedString.Key:Any] = [
            .font:UIFont.init(name: "DIN Alternate", size: 15)!,
            .foregroundColor:APP_GREEN_COLOR()
        ]
        let attr1 = NSAttributedString(string: "创建", attributes: createDiaryButtonAttributes)
        createDiaryButton.setAttributedTitle(attr1, for: .normal)
        createDiaryButton.addTarget(self, action: #selector(createDiary), for: .touchUpInside)
        self.addSubview(createDiaryButton)
        
        //取消按钮
        cancelButton.frame = CGRect(x: 16, y: 44, width: 30, height: 30)
        let cancelButtonAttributes:[NSAttributedString.Key:Any] = [
            .font:UIFont.init(name: "DIN Alternate", size: 15)!,
        ]
        let attr2 = NSAttributedString(string: "取消", attributes: cancelButtonAttributes)
        cancelButton.setAttributedTitle(attr2, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.addSubview(cancelButton)
        
        
    }
    
    
    @objc func createDiary() {
        
        if let createDate = dateString{
            //补日记
            let createdDiary = diaryInfo(dateString: createDate)
            LWRealmManager.shared.add(createdDiary)
            let selectedDiary = createdDiary
            monthVC.configureDataSource(year: monthVC.selectedYear, month: monthVC.selectedMonth)
            
            /*
             先关闭popover，然后跳转到todayVC
             */
            let dismissQueue = DispatchQueue(label: "串行")
            dismissQueue.sync {
                self.monthVC.popover.dismiss()
            }
            dismissQueue.sync {
                //TODO:打开todayVC
            }
        }
        
        
    }
    
    @objc func cancel() {
        monthVC.popover.dismiss()
    }
    
    
}
