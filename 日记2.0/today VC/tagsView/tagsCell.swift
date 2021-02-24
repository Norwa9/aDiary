//
//  tagsCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import UIKit

class tagsCell: UITableViewCell {
    weak var tagsView:tagsView!
    static let reusableId = "tagsCell"
    var tagString:String!
    var bar:UIView!
    var barFrame:CGRect!
    var contentViewFrame:CGRect!
    var hasGetCorrectFrame = false
    @IBOutlet weak var tagsLabel:UILabel!
    var hasSelected:Bool = false{
        didSet{
            animateSelectedView(setTo: hasSelected)
        }
    }
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configUI()
    }

    func configUI(){
        //bar view
        bar = UIView()
        bar.layer.cornerRadius = 2
//        bar.backgroundColor = UIColor.lightGray
        bar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        bar.clipsToBounds = true
        bar.layer.masksToBounds = true
        self.insertSubview(bar, belowSubview: tagsLabel)
    }
    
    override func layoutSubviews() {
        //layoutSubviews再每次布局发生变化时调用
//        print("tagsCell layoutSubviews called")
        if !hasGetCorrectFrame{//开关
            hasGetCorrectFrame = true
            //获取正确的contentView frame和tagsLabel frame，并设置bar的正确的frame
            tagsLabel.sizeToFit()
            bar.frame = CGRect(x: 0, y: 0, width: tagsLabel.frame.width, height: 2)
            bar.center.x = contentView.center.x
            bar.center.y = tagsLabel.frame.maxY + 2
            barFrame = bar.frame//bar的原始frame
            contentViewFrame = contentView.frame//contentView的原始frame
        }
        
    }
    
    func animateSelectedView(setTo animate:Bool,duration:TimeInterval = 0.35){
        if animate == false{
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.bar.frame = self.barFrame
                self.bar.layer.cornerRadius = 2
            } completion: { (_) in
                
            }
        }else{
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.bar.frame = self.contentViewFrame.insetBy(dx: 30, dy: 8)
                self.bar.layer.cornerRadius = 10
            } completion: { (_) in
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
}

extension tagsCell:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}
