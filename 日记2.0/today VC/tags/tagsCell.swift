//
//  tagsCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import UIKit

protocol tagsCellEditProtocol {
    func editButtonDidTapped(tag:String)
}


class tagsCell: UITableViewCell {
    var delegate:tagsCellEditProtocol!
    static let reusableId = "tagsCell"
    
    @IBOutlet weak var tagSelectedPromptView:UIView!
    @IBOutlet weak var tagsLabel:UILabel!
    @IBOutlet weak var selectedImageView:UIImageView!
    @IBOutlet weak var selectedContainerView:UIView!
    @IBOutlet weak var editButton:UIButton!
    
    ///是否被选中
    var hasSelected:Bool = false
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellView()
    }

    func setupCellView(){
        self.backgroundColor = .clear
        
        //tags
        tagSelectedPromptView.layer.cornerRadius = 7
        tagSelectedPromptView.backgroundColor = .clear
        
        tagsLabel.textColor = .label
        tagsLabel.backgroundColor = .clear
        
        //勾选图标以及其容器视图
        selectedImageView.alpha = 0
        selectedImageView.contentMode = .scaleAspectFit
        selectedContainerView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        selectedContainerView.layer.borderWidth = 1
        selectedContainerView.layer.cornerRadius = 5
        
        editButton.layer.cornerRadius = 4
        editButton.backgroundColor = .lightGray
        editButton.addTarget(self, action: #selector(editBtnDidTapped), for: .touchUpInside)
        
    }
    
    @objc func editBtnDidTapped(){
        delegate.editButtonDidTapped(tag: tagsLabel.text!)
    }
    
    public func setView(hasSelected:Bool,isEditMode:Bool = false){
        self.hasSelected = hasSelected
        
        selectedImageView.alpha = hasSelected ? 1:0
        
        tagSelectedPromptView.backgroundColor = hasSelected ? .systemGray6 : .clear
        
        editButton.alpha = isEditMode ? 1:0
    }
    
    func animateSelectedView(duration:TimeInterval = 0.35){
        LWImpactFeedbackGenerator.impactOccurred(style: .light)
        //取消选中
        if self.hasSelected == true{
            self.hasSelected = false
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
                self.tagSelectedPromptView.backgroundColor = .clear
                selectedImageView.alpha = 0
                
//                selectedImageView.transform = .identity
            } completion: { (_) in
            }
        }else{
        //选中
            self.hasSelected = true
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
                self.tagSelectedPromptView.backgroundColor = .systemGray6
                
//                selectedImageView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
//                selectedImageView.transform = CGAffineTransform(translationX: 0, y: -5)
                selectedImageView.alpha = 1
                
            } completion: { (_) in
                UIView.animate(withDuration: duration * 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut) {
//                    self.selectedImageView.transform = CGAffineTransform(translationX: 0, y: 0)
//                    self.selectedImageView.transform = .identity
                } completion: { (_) in
                    
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
}


