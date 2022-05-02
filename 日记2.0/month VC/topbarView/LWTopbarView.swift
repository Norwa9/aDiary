//
//  topbarView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

enum topbarShowingComponent:Int{
    case filterView
    case dateView
}

class LWTopbarView: UIView {
    var viewModel:monthViewModel
    static let kTopBarViewHeight:CGFloat = 50
    
    var dataLable1:UILabel!
    var dataLable2:UILabel!
    var backwordBtn:UIButton!
    var forwardBtn:UIButton!
    var button0:topbarButton!//日历
    var button1:topbarButton!
    var button2:topbarButton!
    var button3:topbarButton!
    var topbarButtons:[topbarButton] = []
    
    var dateView:LWDateView!
    var filterView:LWFilterView!
    
    init(viewModel:monthViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        initUI()
        setupUIconstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.backgroundColor = LWColorConstatnsManager.LWSoftBGColor
//        self.backgroundColor = .clear
        
        //get current date
        let curYear = viewModel.selectedYear
        let curMonth = viewModel.selectedMonth
        let curDay = viewModel.selectedDay
        
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
        
        dateView = LWDateView(viewModel: viewModel)
        dateView.alpha = 0
        self.addSubview(dateView)
        
        filterView = LWFilterView(viewModel: viewModel)
        filterView.alpha = 0
        self.addSubview(filterView)
    }
    
    
    // MARK: Cons
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
        // print("top bar button size : \(40 * globalConstantsManager.shared.zoomModelScale)")
        
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
        
        dateView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
        
        filterView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
    }
    
    
}

//MARK: -target action
extension LWTopbarView{
    @objc func tapped(sender:topbarButton){
        //animation
        sender.bounceAnimation(usingSpringWithDamping: 0.8)
        
        let monthVC = UIApplication.getMonthVC()
        monthVC?.topBarButtonTapped(button: sender)
    }
    
    @objc func yearChangeAction(_ sender:UIButton){
        if let monthVC = UIApplication.getMonthVC(),let viewModel = monthVC.viewModel{
            if sender.tag == 0{
                viewModel.selectedYear -= 1
            }else{
                viewModel.selectedYear += 1
            }
            monthVC.updateUIForDateChange()
        }
    }
}

//MARK: UI更新
extension LWTopbarView{
    /// 进入搜索界面
    public func updateUIForFilterMode(){
        let toShow = viewModel.isFilterMode
        
        // 1. 更新Label和Button
        if toShow{//进入搜索模式
            button3.image = UIImage(named: "back") //searh图标是临时添加到button3上面的
            dataLable1.text = "搜索"
            dataLable2.text = "共\(LWRealmManager.shared.localDatabase.count)篇，\(dataManager.shared.getTotalWordcount())字"
            dataLable1.sizeToFit() // 更新tempLabel1的宽度，使得rectbar1能够正确匹配它的长度
            dataLable2.sizeToFit()
            forwardBtn.alpha = 0
            backwordBtn.alpha = 0
        }else{//退出搜索模式
            button3.image = UIImage(named: "search")
            dataLable1.text = "\(viewModel.selectedYear)年"
            dataLable2.text = "\(viewModel.selectedMonth)月"
            dataLable1.sizeToFit()
            forwardBtn.alpha = 1
            backwordBtn.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.button0.alpha = toShow ? 0:1 // 关闭日历按钮
        } completion: { (_) in}
        
        // 2. 修改UI
        self.filterView.updateUIForToggle(toShow: toShow)
        
        // 3. 修改布局约束
        updateTopbarCons(showingComponent: .filterView,view: self.filterView,toShow: toShow)
    }
    
    /// 展示/收回DateView
    public func updateUIForDateView(){
        let toShow = viewModel.isShowingDateView
        // 0. topbarView没有需要为DateView更新的视图
        // 1. 修改UI
        dateView.updateUIForToggle(toShow: toShow)
        // 2. 修改布局约束
        updateTopbarCons(showingComponent: .dateView,view: self.dateView, toShow: toShow)
    }
    
    /// 当打开filter或dateView时，topbar的高度要做出改变
    private func updateTopbarCons(showingComponent:topbarShowingComponent,view:UIView,toShow:Bool){
        // 1. topbarView高度约束
        let dynamicTopbarViewH:CGFloat
        switch showingComponent {
        case .filterView:
            dynamicTopbarViewH = toShow ?
            (LWTopbarView.kTopBarViewHeight + LWFilterView.kFilterViewHeight)
            : LWTopbarView.kTopBarViewHeight
        case .dateView:
            dynamicTopbarViewH = toShow ?
            (LWTopbarView.kTopBarViewHeight + dateView.kmonthBtnStackViewHeight + dateView.kCalendarHeight)
            : LWTopbarView.kTopBarViewHeight
        }
        self.snp.updateConstraints { (update) in
            update.height.equalTo(dynamicTopbarViewH)
        }
        
        
        // 2. topbarView组件的约束
        switch showingComponent {
        case .filterView:
            filterView.snp.updateConstraints { make in
//                make.bottom.equalToSuperview().offset(toShow ? LWFilterView.kFilterViewHeight : 0)
            }
        case .dateView:
            dateView.snp.updateConstraints { make in
//                make.bottom.equalToSuperview().offset(toShow ? dateView.kmonthBtnStackViewHeight + dateView.kCalendarHeight : 0)
            }
        }
        
        
        // 3. 组件的透明度
        let alpha = toShow ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
            view.alpha = alpha
            self.superview?.layoutIfNeeded()
        } completion: { (_) in}
    }
    
    
    /// 更新搜索结果
    public func updateUIAfterFilter(diaryNum:Int,wordCount:Int){
        dataLable2.text = "共\(diaryNum)篇，\(wordCount)字"
    }

    /// 切换月份后更新UI
    public func updateUIForDateChange(){
        // 1. 更新topbar的标签
        //更新dataLable1
        dataLable1.text = "\(viewModel.selectedYear)年"
        dataLable1.sizeToFit()
        
        self.dataLable2.text = "\(viewModel.selectedMonth)月"
        self.dataLable2.sizeToFit()
        
        // 2. 更新dateView
        dateView.updateUIForDateChange()
    }
}
