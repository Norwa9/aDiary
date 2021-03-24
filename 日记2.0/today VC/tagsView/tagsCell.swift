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
    
    lazy var tagSelectedIcon:UIImageView = {
        let image = UIImage(named: "tagSelected")!
        let view = UIImageView(image: image)
        view.alpha = 0
        view.contentMode = .scaleAspectFill
        self.addSubview(view)
        return view
    }()
    
    lazy var tagSelectedBGView:UIView = {
        let view = UIView()
        view.alpha = 0
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        self.addSubview(view)
        return view
    }()
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellView()
    }

    func setupCellView(){
        print("setupCellView called")
        
        
    }
    
    //cell里子视图的布局都应该在layoutSubviews()里设置
    //layoutSubviews再每次布局发生变化时调用
    override func layoutSubviews() {
        //获取cell的真实frame
        tagsLabel.sizeToFit()
        contentViewFrame = contentView.frame//contentView的原始frame
        tagsLabelFrame = CGRect(//tagsLabel的原始frame
            x: contentViewFrame!.midX - tagsLabel.frame.width / 2.0,
            y: tagsLabel.frame.origin.y,
            width: tagsLabel.frame.width,
            height: tagsLabel.frame.height
        )
        
        if let tagsLabelFrame = tagsLabelFrame{
            //布局tagSelectedIcon
            tagSelectedIcon.frame.origin = CGPoint(x: tagsLabelFrame.maxX + 5, y: tagsLabelFrame.minY)
            tagSelectedIcon.frame.size = CGSize(width: tagsLabelFrame.height, height: tagsLabelFrame.height)
            
            //布局tagSelectedBGView
            tagSelectedBGView.frame.origin = CGPoint(x: tagsLabelFrame.minX - 4, y: tagsLabelFrame.minY - 2)
            tagSelectedBGView.frame.size = CGSize(
                width: tagSelectedIcon.frame.maxX - tagsLabelFrame.minX + 4,
                height: tagsLabelFrame.height + 4
            )
            
        }
        
    }
    
    func animateSelectedView(setTo animate:Bool,duration:TimeInterval = 0.35){
        //取消选中
        if animate == false{
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) { [self] in
                tagSelectedIcon.alpha = 0
                tagSelectedBGView.alpha = 0
            } completion: { (_) in
            }
        }else{
        //选中
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) { [self] in
                tagSelectedIcon.alpha = 1
//                tagSelectedBGView.alpha = 1
            } completion: { (_) in
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
//        print("prepareForReuse(),text:\(self.tagsLabel.text)")
        tagSelectedIcon.alpha = 0
//        tagSelectedBGView.alpha = 0
    }
    
}

extension tagsCell:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}


