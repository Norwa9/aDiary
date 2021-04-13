//
//  pageViewContainer.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import LocalAuthentication
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(authenticate), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(Encrypt), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func configureTopBar(){
        topBar = topbarView(frame: CGRect(x: 0, y: 0, width: 414, height: 106))
        self.view.addSubview(topBar)
    }
    
    func configurePageVC(){
        
        print("configurePageVC")
        
        pageViewController.pageViewContainer = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)//设置pageViewController为容器控制器的子
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
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
//MARK:-
extension pageViewContainer{
    @objc func Encrypt(){
        guard userDefaultManager.useBiometrics || userDefaultManager.usePassword else{
            return
        }
        topBar.alpha = 0
        containView.alpha = 0
    }
    
    @objc func authenticate(){
        guard userDefaultManager.useBiometrics || userDefaultManager.usePassword  else{
            return
        }
        //解密前加密
        Encrypt()
        //解密
        //设置了生物识别
        if userDefaultManager.useBiometrics{
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                let reason = "需要认证你的身份"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){
                    [weak self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            //成功
                            self?.unlock()
                        }else{
                            //失败
                            //提示用户输入密码
                            self!.passwordPrompt()
                        }
                    }
                }
            }else{
                //不能使用生物识别
                //..
            }
        //仅设置密码
        }else if userDefaultManager.usePassword{
            //提示用户输入密码
            self.passwordPrompt()
        }
        
    }
    
    //提示输入密码
    func passwordPrompt(){
        let ac = UIAlertController(title: "解锁App", message: "请输入App密码", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "提交", style: .default){[weak self] _ in
            guard let inputPassword = ac.textFields?[0].text else {return}

            if inputPassword == userDefaultManager.password{
                //密码配对成功
                self?.unlock()
            }else{
                //密码配对失败
                //...
            }
        })
        self.present(ac, animated: true)
    }
    
    func unlock(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            self.topBar.alpha = 1
            self.containView.alpha = 1
        } completion: { (_) in
            
        }
    }
    
    
}





