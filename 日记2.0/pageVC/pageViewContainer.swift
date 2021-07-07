//
//  pageViewContainer.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

/*
 容器控制器：其view由两个子视图组成topbar和pageVC.view
 */
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
        
        //添加到pageVC到当前的容器控制器当中，
        self.addChild(pageViewController)
        //设置pageViewController为容器控制器的子VC，但是注释掉也不影响事件的监听？
        //pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(pageViewController.view)//containView完全可以用self.view替代
        pageViewController.view.backgroundColor = .white
        NSLayoutConstraint.activate([
            containView.topAnchor.constraint(equalTo: pageViewController.view.topAnchor),
            containView.bottomAnchor.constraint(equalTo: pageViewController.view.bottomAnchor),
            containView.leadingAnchor.constraint(equalTo: pageViewController.view.leadingAnchor),
            containView.trailingAnchor.constraint(equalTo: pageViewController.view.trailingAnchor),
        ])
    }
    
    
}






