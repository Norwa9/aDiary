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
    let topbarHeight:CGFloat = 60
    lazy var pageViewController:customPageViewController = {
        let customPageVC = storyboard?.instantiateViewController(identifier: "customPageVC") as! customPageViewController
        return customPageVC
    }()
    
    var currenVCindex:Int = 0
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopBar()
        
        configurePageVC()
        
        pageControl.isUserInteractionEnabled = false
        
        //设置布局
        topBar.translatesAutoresizingMaskIntoConstraints = false//重要！
        containView.translatesAutoresizingMaskIntoConstraints = false//重要！
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topBar.bottomAnchor.constraint(equalTo: containView.topAnchor),
            topBar.heightAnchor.constraint(equalToConstant: topbarHeight),
            
            containView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.layoutIfNeeded()
    }
    
    
    func configureTopBar(){
        topBar = topbarView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topbarHeight))
        self.view.addSubview(topBar)
    }
    
    func configurePageVC(){
        
        pageViewController.pageViewContainer = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)//设置pageViewController为容器控制器的子
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
//        pageViewController.view.layer.borderWidth = 1
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






