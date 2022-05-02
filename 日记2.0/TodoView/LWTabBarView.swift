//
//  LWTabBarView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/11.
//  模拟TabBarViewController，但只是用于切换monthVC的layout

import UIKit

class LWTabBarView: UIView {
    static let viewHeight:CGFloat = 80.0
    var currentTabBarIndex = 0
    private var delegate:monthVC!
    private var diaryItem:LWTabBarItem!
    private var todoItem:LWTabBarItem!
    private var blurEffectView:UIVisualEffectView!
    
    init(delegate:monthVC) {
        super.init(frame: .zero)
        self.delegate = delegate
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        // 图标：https://www.iconfont.cn/collections/detail?spm=a313x.7781069.0.da5a778a4&cid=24347
        diaryItem = LWTabBarItem(title:"日记",imageName: "diaryIcon")
        let showDiaryTapGes = UITapGestureRecognizer(target: self, action: #selector(showDiaryList))
        diaryItem.addGestureRecognizer(showDiaryTapGes)
        diaryItem.isSelected = true
        
        todoItem = LWTabBarItem(title:"待办",imageName: "todoIcon")
        let showTodoTapGes = UITapGestureRecognizer(target: self, action: #selector(showTodoList))
        todoItem.addGestureRecognizer(showTodoTapGes)
        
        
        self.addSubview(diaryItem)
        self.addSubview(todoItem)
        self.layoutBottomGradientView()
        
        
        
    }
    
    private func setCons(){
        let centerInset:CGFloat = 10
        let padding:CGFloat = 2
        diaryItem.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.bottom.equalToSuperview().offset(-padding)
            make.right.equalTo(self.snp.centerX).offset(-centerInset)
        }
        
        todoItem.snp.makeConstraints { make in
            make.centerY.equalTo(diaryItem)
            make.height.equalTo(self.diaryItem.snp.height)
            make.width.equalTo(self.diaryItem.snp.width)
            make.left.equalTo(self.snp.centerX).offset(centerInset)
        }
    }
    
    ///布局底部渐变图层
    private func layoutBottomGradientView(){
        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false
//        let gradientLayer = CAGradientLayer()//底部创建渐变层
//        gradientLayer.colors = [UIColor.clear.cgColor,
//                                UIColor.label.cgColor]
//        gradientLayer.frame = blurEffectView.bounds
//        gradientLayer.locations = [0,0.9,1]
//        blurEffectView.layer.mask = gradientLayer
        self.insertSubview(blurEffectView, at: 0)
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func updateGraddientView(){
//        print("更新底部阴影")
//        blurEffectView.removeFromSuperview()
//        layoutBottomGradientView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if UITraitCollection.current.userInterfaceStyle == .dark{
//            blurEffectView.alpha = 0
//        }else{
//            blurEffectView.alpha = 1
//        }
    }
    
    //MARK: @objc
    @objc func showDiaryList(){
        // 震动
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if !diaryItem.isSelected{
            diaryItem.isSelected.toggle()
        }else{
            return
        }
        if todoItem.isSelected{
            todoItem.isSelected = false
        }
        
        layoutParasManager.shared.tabbarType = 0
        delegate.reloadCollectionViewAndDateView()
        
        
    }
    
    @objc func showTodoList(){
        // 震动
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if !todoItem.isSelected{
            todoItem.isSelected.toggle()
        }else{
            return
        }
        if diaryItem.isSelected{
            diaryItem.isSelected = false
        }
        layoutParasManager.shared.tabbarType = 1
        delegate.reloadCollectionViewAndDateView()
        
    }
    
    
}
