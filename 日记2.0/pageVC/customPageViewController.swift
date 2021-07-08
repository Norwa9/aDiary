//
//  customPageViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

class customPageViewController: UIPageViewController {
    let viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let todayVC = sb.instantiateViewController(identifier: "todayVC") as! todayVC
        
        let monthVC = sb.instantiateViewController(identifier: "monthVC") as! monthVC
        
        return [todayVC,monthVC]
    }()
    
    var curVCIndex = 0{
        didSet{
            pageViewContainer.topBar.currentVCindex = curVCIndex
            pageViewContainer.pageControl.currentPage = curVCIndex
        }
    }
    weak var pageViewContainer:pageViewContainer!
    var pageScrollView:UIScrollView!
    var percentComplete:CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //配置page view controller
        self.delegate = self
        self.dataSource = self
        
        //链接
        for vc in viewControllerList {
            if let vc = vc as? monthVC{
                vc.topbar = pageViewContainer.topBar
                vc.pageVC = self
            }else if let vc = vc as? todayVC{
                vc.topbar = pageViewContainer.topBar
            }
        }
        
//        预载，防止pageVC滑动时卡顿
        for vc in viewControllerList{
            vc.view.layoutIfNeeded()
        }
        
        //设置pageVC的scrollview代理，目的是求左右滑动切换VC时的偏移量
        for subView in view.subviews {
            if let subView = subView as? UIScrollView {
                pageScrollView = subView
                subView.delegate = self
            }
        }
        
        //设置pageVC的主页，将调用主页的viewWillAppear
        if let firstViewController = viewControllerList.first{
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

}

extension customPageViewController:UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else{return nil}
        
//        curVCIndex -= 1
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0, previousIndex < viewControllerList.count else{
            return  nil
        }
        
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else{return nil}
//        curVCIndex += 1
        
        let nextIndex = vcIndex + 1
        
        guard nextIndex < viewControllerList.count,viewControllerList.count != nextIndex else{
            return nil
        }
        
        return viewControllerList[nextIndex]
    }
    
    func slideToTodayVC(selectedDiary:diaryInfo,completion: (() -> Void)?) {
        guard let todayVC = viewControllerList[0] as? todayVC else{
            return
        }
        view.isUserInteractionEnabled = false//阻止cell被用户连按两下
        //读取选取日记
        todayVC.loadTodayData(selectedDiary: selectedDiary)
        //让pageController滑动到今日页面
        self.setViewControllers([todayVC], direction: .reverse, animated: true, completion: {[weak self] (complete: Bool) -> Void in
        if (complete) {
            self?.curVCIndex = 0
            self?.view.isUserInteractionEnabled = true
          completion?()
        }
        })
    }
    
    //更新index
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if percentComplete > 0.9{
            //阈值=0.9，可以防止topbar label显示错乱的问题
            curVCIndex = pageViewController.viewControllers!.first!.view.tag
        }
    }
    
}

extension customPageViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
//        print(curVCIndex,point.x)
        let screenWidth = UIScreen.main.bounds.width
        if (curVCIndex == 0 && point.x < screenWidth) || (curVCIndex == 1 && point.x > screenWidth){
            return
        }
        //计算左右滑动的完成进度
        percentComplete = abs(point.x - self.view.frame.size.width)/self.view.frame.size.width
        
        //animate topbar
        pageViewContainer.topBar.animateButtons(currenVCindex: curVCIndex, percentComplete: percentComplete)
        pageViewContainer.topBar.animateDateLabels(currenVCindex: curVCIndex, percentComplete: percentComplete)
    }
}

