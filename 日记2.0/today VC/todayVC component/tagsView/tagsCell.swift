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
    
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var tagsLabel:UILabel!
    @IBOutlet weak var selectionPropt:UIImageView!
    @IBOutlet weak var selectionProptContainer:UIView!
    @IBOutlet weak var editButton:UIButton!
    
    ///是否被选中
    var hasSelected:Bool = false
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellView()
    }

    func setupCellView(){
        containerView.layer.cornerRadius = 7
        
        selectionPropt.alpha = 0
        selectionPropt.contentMode = .scaleAspectFit
        
        selectionProptContainer.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        selectionProptContainer.layer.borderWidth = 1
        selectionProptContainer.layer.cornerRadius = 5
        
        editButton.layer.cornerRadius = 4
        editButton.backgroundColor = .lightGray
        editButton.addTarget(self, action: #selector(editBtnDidTapped), for: .touchUpInside)
        
    }
    
    @objc func editBtnDidTapped(){
        delegate.editButtonDidTapped(tag: tagsLabel.text!)
    }
    
    func setView(hasSelected:Bool,isEditMode:Bool = false){
        self.hasSelected = hasSelected
        selectionPropt.alpha = hasSelected ? 1:0
        containerView.backgroundColor = hasSelected ? UIColor.colorWithHex(hexColor: 0xF7F5F2) : .white
        
        editButton.alpha = isEditMode ? 1:0
    }
    
    func animateSelectedView(duration:TimeInterval = 0.35){
        //取消选中
        if self.hasSelected == true{
            self.hasSelected = false
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
                self.containerView.backgroundColor = .white
                selectionPropt.alpha = 0
                
                selectionPropt.transform = .identity
            } completion: { (_) in
            }
        }else{
        //选中
            self.hasSelected = true
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
                self.containerView.backgroundColor = UIColor.colorWithHex(hexColor: 0xF7F5F2)
                
                selectionPropt.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                selectionPropt.transform = CGAffineTransform(translationX: 0, y: -5)
                selectionPropt.alpha = 1
                
            } completion: { (_) in
                UIView.animate(withDuration: duration * 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut) {
                    self.selectionPropt.transform = CGAffineTransform(translationX: 0, y: 0)
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


