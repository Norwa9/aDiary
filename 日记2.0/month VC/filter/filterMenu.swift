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
    @IBOutlet weak var sortStyleSegmentControl:UISegmentedControl!
    
    func configureUI(){
        //sortStyleSegmentControl
        sortStyleSegmentControl.addTarget(self, action: #selector(sortStyleChange(_:)), for: .valueChanged)
        sortStyleSegmentControl.selectedSegmentIndex = filterModel.shared.selectedSortstyle.rawValue        //恢复选取的值
        
        //doneButton
        doneButton.layer.cornerRadius = 5
        doneButton.setupShadow()

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

