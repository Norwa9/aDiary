//
//  LWSoundView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit

class LWSoundView:UIView{
    /// 底部容器视图
    var containerView:UIView!
    
    /// 开始播放按钮
    var playButton:LWPlayButton!
    
    /// 音频文件label
    var fileNameLabel:UILabel!
    
    /// 计时label
    /// 用来显示音频时长，以及播放时用来计时
    var timingLabel:UILabel!
    
    /// 创建时间
    var createTimeLabel:UILabel!

    /// 更多选项
    var moreButton:UIButton!
    
    var viewModel:LWSoundViewModel
    
    init(viewModel:LWSoundViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.bounds)
        self.viewModel.soundView = self
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    func initUI(){
        // containerView
        containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 5
        containerView.addBorder(width: 1, color: soundViewDynamicColor)
        
        playButton = LWPlayButton()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(playBtnDidTapped))
        playButton.addGestureRecognizer(tapGes)
    
        fileNameLabel = UILabel()
        fileNameLabel.attributedText = viewModel.getFileName()
        
        timingLabel = UILabel()
        viewModel.updateProgress()
        
        createTimeLabel = UILabel()
        createTimeLabel.attributedText = viewModel.getCreateTime()
        
        // moreButton
        moreButton = UIButton()
        moreButton.setImage(UIImage(named: "more"), for: .normal)
        moreButton.addTarget(self, action: #selector(moreBtnDidTapped), for: .touchUpInside)
        
        
        self.addSubview(containerView)
        containerView.addSubview(playButton)
        containerView.addSubview(fileNameLabel)
        containerView.addSubview(timingLabel)
        containerView.addSubview(createTimeLabel)
        containerView.addSubview(moreButton)
    }
    
    //MARK: Constraint
    private func setCons(){
        self.snp.makeConstraints { make in
            make.width.equalTo(viewModel.bounds.width)
            make.height.equalTo(viewModel.bounds.height)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.playButton.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(playButton.snp.height)
        }
        
        self.fileNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalTo(playButton.snp.right).offset(5)
            make.right.equalTo(moreButton.snp.left)
        }
        
        self.timingLabel.snp.makeConstraints { make in
            make.left.equalTo(fileNameLabel)
            make.top.equalTo(fileNameLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        self.createTimeLabel.snp.makeConstraints { make in
            //make.left.equalTo(timingLabel.snp.right).offset(10)
            make.centerY.equalTo(timingLabel)
            //make.right.lessThanOrEqualTo(moreButton.snp.left).offset(-5)
            make.right.equalTo(moreButton.snp.left).offset(-5)
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            let fontHeight = userDefaultManager.font.lineHeight
            make.size.equalTo(CGSize(width: fontHeight, height: fontHeight))
        }
        
        layoutIfNeeded() // 立即更新布局。否则.asImage()不能产生图像，这是因为UIView在被添加到视图层级之时，才会进行布局。
    }
    
    
    @objc func playBtnDidTapped(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if viewModel.isPlaying{
            viewModel.stopPlaying()
        }else{
            viewModel.startPlaying()
        }
        
        
    }
    
    @objc func moreBtnDidTapped(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        
        let vc = LWSoundSettingViewController(viewModel: viewModel)
        UIApplication.getTodayVC()?.present(vc, animated: true, completion: nil)
    }
    
}

//MARK:  -切换深色模式监听事件
extension LWSoundView{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if UITraitCollection.current.userInterfaceStyle == .dark{
            containerView.addBorder(width: 1, color: soundViewDynamicColor)
        }else{
            containerView.addBorder(width: 1, color: soundViewDynamicColor)
        }
    }

}
