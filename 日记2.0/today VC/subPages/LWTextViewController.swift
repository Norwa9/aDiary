//
//  LWTextViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/21.
//

import UIKit
import JXPagingView

class LWTextViewController: UIViewController {
    let textView = LWTextView()
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
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
