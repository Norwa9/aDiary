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
    var barFrame:CGRect!
    var contentViewFrame:CGRect?
    var tagsLabelFrame:CGRect?
    var hasGetCorrectFrame = false
    @IBOutlet weak var tagsLabel:UILabel!
    var hasSelected:Bool = false{
        didSet{
            animateSelectedView(setTo: hasSelected)
        }
    }
    
    var tagSelectedIcon:UIImageView = {
        let image = UIImage(named: "tagSelected")!
        let view = UIImageView(image: image)
        view.alpha = 0
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    var tagSelectedBGView:UIView = {
        let view = UIView()
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        return view
    }()
    
//    var cellBGView:UIView = {
//        
//    }()
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellView()
    }

    func setupCellView(){
        self.addSubview(tagSelectedIcon)
        self.insertSubview(tagSelectedBGView, belowSubview: tagSelectedIcon)
    }
    
    //cell里子视图的布局都应该在layoutSubviews()里设置
    //layoutSubviews再每次布局发生变化时调用
    override func layoutSubviews() {
        //获取cell的真实frame
        tagsLabel.sizeToFit()
        contentViewFrame = contentView.frame//contentView的真实frame
        tagsLabelFrame = tagsLabel.frame//tagsLabel的真实frame
        
        if let tagsLabelFrame = tagsLabelFrame{
            //布局tagSelectedIcon
            let iconWidth = tagsLabelFrame.height
            tagSelectedIcon.frame.origin = CGPoint(x: tagsLabelFrame.minX - iconWidth - 2, y: tagsLabelFrame.minY)
            tagSelectedIcon.frame.size = CGSize(width: iconWidth, height: iconWidth)
            
            //布局tagSelectedBGView
            tagSelectedBGView.frame = tagSelectedIcon.frame.insetBy(dx: -1, dy: -1)
        }
        
    }
    
    func animateSelectedView(setTo animate:Bool,duration:TimeInterval = 0.35){
        //取消选中
        if animate == false{
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
                tagSelectedIcon.alpha = 0
                tagSelectedIcon.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } completion: { (_) in
            }
        }else{
        //选中
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
                tagSelectedIcon.alpha = 1
                tagSelectedIcon.transform = .identity
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


