//
//  pageViewContainer.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

class pageViewContainer: UIViewController {
    @IBOutlet weak var containView: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    var topBar:topbarView!
    lazy var pageViewController:customPageViewController = {
        let customPageVC = storyboard?.instantiateViewController(identifier: "customPageVC") as! customPageViewController
        return customPageVC
    }()
    
    var currenVCindex:Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopBar()
        configurePageVC()
        
    }
    
    func configureTopBar(){
        topBar = topbarView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 106))
        topBar.layer.borderWidth = 1
        self.view.addSubview(topBar)
    }
    
    func configurePageVC(){
        
        print("configurePageVC")
        
        pageViewController.pageViewContainer = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)//设置pageViewController为容器控制器的子
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.layer.borderWidth = 1
        containView.addSubview(pageViewController.view)
        pageViewController.view.backgroundColor = .white
        NSLayoutConstraint.activate([
            containView.topAnchor.constraint(equalTo: pageViewController.view.topAnchor),
            containView.bottomAnchor.constraint(equalTo: pageViewController.view.bottomAnchor),
            containView.leadingAnchor.constraint(equalTo: pageViewController.view.leadingAnchor),
            containView.trailingAnchor.constraint(equalTo: pageViewController.view.trailingAnchor),
        ])
        
    }
    
}






