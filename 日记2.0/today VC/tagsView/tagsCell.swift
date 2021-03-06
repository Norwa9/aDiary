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
    var tagsLabelFrame:CGRect!
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
        bar.clipsToBounds = true
        self.bar.backgroundColor = .white
        bar.layer.masksToBounds = true
        self.addSubview(bar)
        self.sendSubviewToBack(bar)
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
            tagsLabelFrame = CGRect(//tagsLabel的原始frame
                x: contentViewFrame.midX - tagsLabel.frame.width / 2.0,
                y: tagsLabel.frame.origin.y,
                width: tagsLabel.frame.width,
                height: tagsLabel.frame.height
            )
        }
        
    }
    
    func animateSelectedView(setTo animate:Bool,duration:TimeInterval = 0.35){
        //取消选中
        if animate == false{
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.bar.frame = self.barFrame
                self.bar.layer.cornerRadius = 2
                self.bar.backgroundColor = .white
            } completion: { (_) in
                
            }
        }else{
        //选中
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.bar.frame = self.tagsLabelFrame.insetBy(dx: -3, dy: -1)
                self.bar.layer.cornerRadius = 10
                self.bar.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9490196078, blue: 0.9490196078, alpha: 1).withAlphaComponent(0.7)
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
