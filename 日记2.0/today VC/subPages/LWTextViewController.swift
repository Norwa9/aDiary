//
//  LWTextViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/21.
//

import UIKit
import JXPagingView

class LWTextViewController: UIViewController {
    var model:diaryInfo!
    
    var textForamtter:TextFormatter!
    
    let textView = LWTextView()
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupConstraints()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func initUI(){
        self.view.addSubview(textView)
        textView.delegate = self
    }
    
    private func setupConstraints(){
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func load(){
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.loadTextViewContent(with: model)
    }
    
    
    
}

extension LWTextViewController : UITextViewDelegate{
    
}

extension LWTextViewController : JXPagingViewListViewDelegate,UIScrollViewDelegate{
    func listView() -> UIView {
        self.view
    }
    
    func listScrollView() -> UIScrollView {
        self.textView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
    
    
    
}
