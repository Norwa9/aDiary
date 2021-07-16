//
//  filterMenu.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/8.
//

import UIKit

class filterMenu: UIView {
    weak var monthVC:monthVC!
    var contentView:UIView!
    @IBOutlet weak var tableView:UITableView!
    
    let buttonSize = CGSize(width: 40, height: 40)
    @IBOutlet weak var doneButton:UIButton!
    lazy var buttons = [moodButton]()
    @IBOutlet weak var sortStyleSegmentControl:UISegmentedControl!
    
    //初始化默认属性配置
    func configureUI(){
        //sort style
        sortStyleSegmentControl.addTarget(self, action: #selector(sortStyleChange(_:)), for: .valueChanged)
        //恢复选取值
        sortStyleSegmentControl.selectedSegmentIndex = filterModel.shared.selectedSortstyle.rawValue
        
        
        //mood buttons
        for i in 0..<3 {
            let button = moodButton(frame: CGRect(origin: CGPoint(x: 130 + CGFloat(i) * 50, y: 103), size: buttonSize))
            button.moodType = moodTypes.allCases[i]
            button.addTarget(self, action: #selector(moodButtonTapped(sender:)), for: .touchUpInside)
            self.addSubview(button)
            buttons.append(button)
        }
        doneButton.layer.cornerRadius = 5
        doneButton.setupShadow()
        
        //恢复选取值
        if let selectedMood = filterModel.shared.selectedMood,let index = moodTypes.allCases.firstIndex(of: selectedMood){
            let selectedButton = buttons[index]
            moodButtonTapped(sender: selectedButton)
        }
        
        
        //table view
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: tagsCell.reusableId, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: tagsCell.reusableId)
        tableView.separatorStyle = .none

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //布局相关设置：layoutSubviews()中可以获取autolayout后view的准确frame
    }
    
    //button target
    @objc func moodButtonTapped(sender:moodButton){
        for button in buttons{
            if button == sender{
                sender.animateSelectedView()
            }else{
                //关闭其他按钮
                if button.hasSelected{
                    button.animateSelectedView()
                }
            }
        }
        
        //查看选择了哪个mood
        for button in buttons{
            if button.hasSelected{
                filterModel.shared.selectedMood = button.moodType
                return
            }
        }
        //没有选择mood
        filterModel.shared.selectedMood = nil
        
    }
    
    @IBAction func done(){
        monthVC.popover.dismiss()
        monthVC.filter()
        monthVC.animateFilterButton(hasPara: true)
    }
    
    @objc func sortStyleChange(_ sender:UISegmentedControl){
        let index = sender.selectedSegmentIndex
        filterModel.shared.selectedSortstyle = sortStyle.init(rawValue: index)!
    }
    
   
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadViewFromNib()
        addSubview(contentView)
        setUpConstraint()
        //初始化属性配置
        configureUI()
    }
     
     //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = loadViewFromNib()
        addSubview(contentView)
        setUpConstraint()
        //初始化属性配置
        configureUI()
    }
    
    //加载xib
    func loadViewFromNib() -> UIView{
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func setUpConstraint(){
        contentView.fillSuperview()
    }
    
}

//MARK:-tableView delegate
extension filterMenu:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.shared.tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tagsCell.reusableId) as! tagsCell
        let row = indexPath.row
        let text = dataManager.shared.tags[row]
        cell.tagsLabel.text = text
        let selectedState = filterModel.shared.selectedTags.contains(text)
        cell.setView(hasSelected: selectedState)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! tagsCell
        let row = indexPath.row
        
        cell.animateSelectedView()
        
        let tag = dataManager.shared.tags[row]
        //选取，反选
        if let firstIndex = filterModel.shared.selectedTags.firstIndex(of: tag){
            filterModel.shared.selectedTags.remove(at: firstIndex)
        }else{
            filterModel.shared.selectedTags.append(tag)
        }
    }
    
}

