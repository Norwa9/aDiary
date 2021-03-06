//
//  exportSettingViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/19.
//

import UIKit
import SnapKit
import SwiftUI

class exportSettingViewController: UIViewController {
    var containerView:UIView!
    
    var viewOriginY:CGFloat?
    private var titleLabel:UILabel!
    private var segControl:UISegmentedControl!
    private var startLabel:UILabel!
    private var endLabel:UILabel!
    private var datePickerStart:UIDatePicker!
    private var datePickerEnd:UIDatePicker!
    private var exportButton:UIButton!
    
    let exportTitle = NSAttributedString(string: "导出").addingAttributes([
        .font : UIFont.systemFont(ofSize: 18, weight: .bold),
        .foregroundColor : UIColor.white
    ])
    
    let exportingTitle = NSAttributedString(string: "稍等").addingAttributes([
        .font : UIFont.systemFont(ofSize: 18, weight: .bold),
        .foregroundColor : UIColor.white
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewOriginY = self.view.frame.origin.y
        initUI()
        setCons()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.layer.cornerRadius = 10
        
        containerView = UIView()
        containerView.backgroundColor =  .systemBackground
        containerView.layer.cornerRadius = 10
        
        titleLabel = UILabel()
        titleLabel.text = "导出设置"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        segControl = UISegmentedControl(items: ["PDF","Text"])
        segControl.selectedSegmentIndex = 0
        
        startLabel = UILabel()
        startLabel.text = "起始日期"
        startLabel.font = UIFont.systemFont(ofSize: 16)
        endLabel = UILabel()
        endLabel.text = "结束日期"
        endLabel.font = UIFont.systemFont(ofSize: 16)
        
        datePickerStart = UIDatePicker()
        // datePickerStart.preferredDatePickerStyle = .wheels
        datePickerStart.setDate(userDefaultManager.downloadDate ?? Date(), animated: false)
        datePickerStart.datePickerMode = .date
        
        datePickerEnd = UIDatePicker()
        // datePickerEnd.preferredDatePickerStyle = .wheels
        datePickerEnd.setDate(Date(), animated: false)
        datePickerEnd.datePickerMode = .date
        
        exportButton = UIButton()
        exportButton.addTarget(self, action: #selector(export), for: .touchUpInside)
        exportButton.backgroundColor = .black
        exportButton.layer.cornerRadius = 10
        exportButton.setAttributedTitle(exportTitle, for: .normal)
        
        exportManager.shared.completion = { [self] in
            exportButton.setAttributedTitle(exportTitle, for: .normal)
            exportButton.isEnabled = true
        }
        
        
        self.view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(segControl)
        containerView.addSubview(startLabel)
        containerView.addSubview(endLabel)
        containerView.addSubview(datePickerStart)
        containerView.addSubview(datePickerEnd)
        containerView.addSubview(exportButton)
        
    }
    
    private func setCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(18)
        }
        
        segControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        startLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.centerY.equalTo(datePickerStart)
        }
        
        datePickerStart.snp.makeConstraints { make in
            make.top.equalTo(segControl.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        endLabel.snp.makeConstraints { make in
            make.left.equalTo(startLabel)
            make.centerY.equalTo(datePickerEnd)
        }
        
        datePickerEnd.snp.makeConstraints { make in
            make.top.equalTo(datePickerStart.snp.bottom).offset(5)
            make.height.equalTo(datePickerStart)
            make.centerX.equalToSuperview()
            make.right.equalTo(datePickerStart)
        }
        
        exportButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
    }
    
    @objc func export(){
        var startDate = datePickerStart.date
        var endDate = datePickerEnd.date
        let mode = segControl.selectedSegmentIndex
        let calendar = Calendar(identifier: .chinese)
        startDate = calendar.startOfDay(for: startDate)
        endDate = calendar.startOfDay(for: endDate)
        guard !(startDate.compare(endDate) == .orderedDescending) else {
            exportButton.shake()
            return
        }
        exportButton.setAttributedTitle(exportingTitle, for: .normal)
        exportButton.isEnabled = false
        if mode == 0{
            exportManager.shared.exportPDF(startDate: startDate, endDate: endDate)
        }else if mode == 1{
            exportManager.shared.exportText(startDate: startDate, endDate: endDate)
        }
        
    }

}

extension exportSettingViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting,viewHeight: 250)
    }
}
