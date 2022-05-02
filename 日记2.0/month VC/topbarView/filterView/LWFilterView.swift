//
//  LWFilterView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation
import UIKit
import Popover

class LWFilterView: UIView{
    var monthVC = UIApplication.getMonthVC()
    var viewModel:monthViewModel
    var searchBar:UISearchBar!
    var filterMenu:LWFilterMenu!
    var filterButton:topbarButton!
    let popover:Popover = LWPopoverHelper.shared.getFilterPopover()
    static let kFilterViewHeight:CGFloat = 40
    
    init(viewModel:monthViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        //search Bar
        searchBar = UISearchBar()
        searchBar.placeholder = "查找所有日记"
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.enablesReturnKeyAutomatically = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .normal)
        searchBar.delegate = self
        searchBar.alpha = 0
        
        //filterButton
        filterButton = topbarButton(frame: .zero)
        filterButton.image = UIImage(named: "filter")
        filterButton.alpha = 0
        filterButton.addTarget(self, action: #selector(filterButtonDidTapped(sender:)), for: .touchUpInside)
        
        self.addSubview(searchBar)
        self.addSubview(filterButton)
    }
    
    private func setCons(){
        self.snp.makeConstraints { make in
            make.height.equalTo(LWFilterView.kFilterViewHeight)
        }
        
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-50)
        }
        
        filterButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(searchBar.snp.right)
            make.size.equalTo(CGSize(width: 35, height: 35))
        }
    }
    
    /// 呼出搜索过滤
    @objc func filterButtonDidTapped(sender:topbarButton){
        sender.bounceAnimation(usingSpringWithDamping: 0.8)
        
        // filter option menu
        filterMenu = LWFilterMenu(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 315, height:440 )))
        filterMenu.delegate = self
        searchBar.resignFirstResponder()
        popover.show(filterMenu, fromView: filterButton)
    }
    
    
    /// 根据已经输入的条件搜索数据库
    public func filter(){
        let res = viewModel.loadFilteredDataSource()
        monthVC?.reloadAfterFilter(diaryNum: res.0, wordCount: res.1)
    }
    
    /// 进入/退出搜索模式UI切换
    public func updateUIForToggle(toShow:Bool){
        if toShow{
            
        }else{
            searchBar.resignFirstResponder()
            searchBar.searchTextField.text = ""
            filterHelper.shared.clear()//移除所有的搜索参数
        }
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.searchBar.alpha = toShow ? 1:0
            self.filterButton.alpha = toShow ? 1:0
        } completion: { (_) in}
    }
}

extension LWFilterView:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //“取消”按钮
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        filterHelper.shared.searchText = searchBar.text ?? ""
        filter()
    }
}
