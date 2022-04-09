//
//  LWBaseCardViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/4/9.
//

import UIKit

class LWBaseCardViewController: UIViewController {
    var titleLabel:UILabel!
    var containerView:UIView!
    var cardTitle:String
    var cardViewHeight:CGFloat
    
    
    init(cardViewHeight:CGFloat,cardTitle:String) {
        self.cardViewHeight = cardViewHeight
        self.cardTitle = cardTitle
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setCons()
    }
    
    func initUI(){
        containerView = UIView()
        containerView.backgroundColor =  .systemBackground
        containerView.layer.cornerRadius = 10
        
        titleLabel = UILabel()
        titleLabel.text = self.cardTitle
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.view.addSubview(containerView)
        self.view.addSubview(titleLabel)
    }
    
    func setCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(18)
        }
        
    }
    


}

extension LWBaseCardViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting,viewHeight: self.cardViewHeight)
    }
}
