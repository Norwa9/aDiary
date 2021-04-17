//
//  monthCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import UIKit

class monthCell: UICollectionViewCell {
    static let reusableID = "monthCell"
    private lazy var containerView = UIView()
    var contentLabel:UILabel = UILabel()
    
    var dateLabel:UILabel = UILabel()
    var tagsLabel:UILabel = UILabel()
    var moodImageView:UIImageView = UIImageView()
    var islikeImageView:UIImageView = UIImageView()
    var wordNumLabel:UILabel = UILabel()
    var text :String? {
        didSet {
//            //内容
//            contentLabel.text = text
//            //标题
//            let mutable = NSMutableAttributedString(attributedString: contentLabel.attributedText!)
//            contentLabel.attributedText = setTitle(aString: mutable)
        }
    }
    var tags:[String]!{
        didSet{
            var tagsLabelText = ""
            for tag in tags{
                tagsLabelText.append("#" + tag + " ")
            }
            tagsLabel.text = tagsLabelText
        }
    }
    var wordNum:Int = 0{
        didSet{
            wordNumLabel.text = "\(wordNum)字"
            wordNumLabel.sizeToFit()
        }
    }
    var isLike:Bool!{
        didSet{
            if isLike{
                self.islikeImageView.image = #imageLiteral(resourceName: "star2")
            }else{
                self.islikeImageView.image = #imageLiteral(resourceName: "star1")
            }
        }
    }
    var moodType:moodTypes!{
        didSet{
            moodImageView.image = UIImage(named: moodType.rawValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init month cell")
        globalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func globalSetup() {
        setupContainerView()
        setupContentLabelsConstraints()
        
    }
    
    
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        
        let cellPedding:CGFloat = 15//cell距离tableView两边的留白
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 5).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -5).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 95.0).isActive = true
        //限制住contentView的宽度，使之能够在高度根据contentLabel自适应
        containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 2 * cellPedding).isActive = true
        self.layoutIfNeeded()
        //custom containerView
//        containerView.layer.borderWidth = 1
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 10
        containerView.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        
    }
    
    private func setupContentLabelsConstraints() {
        print("private func setupContentLabelsConstraints()")
        //contentLabel
        contentLabel.numberOfLines = 0
        containerView.addSubview(contentLabel)
        contentLabel.font = UIFont(name: userDefaultManager.fontName, size: 14)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //tags Label
        containerView.addSubview(tagsLabel)
        tagsLabel.numberOfLines = 0
        tagsLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        tagsLabel.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        //data Label
        containerView.addSubview(dateLabel)
        dateLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        //word Number Label
        containerView.addSubview(wordNumLabel)
        wordNumLabel.textAlignment = .right
        wordNumLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        wordNumLabel.translatesAutoresizingMaskIntoConstraints = false
        //islikeImageView
        containerView.addSubview(islikeImageView)
        islikeImageView.contentMode = .scaleAspectFill
        //moodImageView
        containerView.addSubview(moodImageView)
        moodImageView.contentMode = .scaleAspectFill
        moodImageView.translatesAutoresizingMaskIntoConstraints = false
       
        
        islikeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK:-Auto layout
        NSLayoutConstraint.activate([
            //contentLabel
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15.0),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15.0),
            contentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5.0),
            contentLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 150),
            contentLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -20.0),
            
            //tags Label
            tagsLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            tagsLabel.heightAnchor.constraint(equalToConstant: 20),
            tagsLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -5),
            
            //date Label
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15.0),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            dateLabel.widthAnchor.constraint(equalToConstant: 130),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            
            //word Number Label
            wordNumLabel.trailingAnchor.constraint(equalTo: islikeImageView.leadingAnchor, constant: -5),
            wordNumLabel.heightAnchor.constraint(equalToConstant: 20),
            wordNumLabel.widthAnchor.constraint(equalToConstant: 50),
            wordNumLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            
            //islikeImageView
            islikeImageView.trailingAnchor.constraint(equalTo: moodImageView.leadingAnchor, constant: -5),
            islikeImageView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            islikeImageView.heightAnchor.constraint(equalToConstant: 20),
            islikeImageView.widthAnchor.constraint(equalToConstant: 20),
            
            //moodImageView
            moodImageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            moodImageView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            moodImageView.heightAnchor.constraint(equalToConstant: 20),
            moodImageView.widthAnchor.constraint(equalToConstant: 20),
            
        ])
        
        
        
    }
    
    //self-sizeing所必须实现的
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = size.height
        newFrame.size.width = 384
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    
    func fillCell(diary:diaryInfo){
        //如果没有这句，cell的自适应高度不准确。
        self.layoutIfNeeded()//(？)这里需要 layoutIfNeeded 一下，否则我们不能同步拿到contentSize，参考自：https://blog.csdn.net/ssy0082/article/details/81711240
        self.contentLabel.attributedText = setContentLabel(content: diary.content)
        self.tags = diary.tags
        self.dateLabel.text = diary.date! + "，" + Date().getWeekday(dateString: diary.date!)
        self.wordNum = diary.content.count
        self.isLike = diary.islike
        self.moodType = diary.mood
        //保持各lablel是最新设置的字体样式
        tagsLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        dateLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        wordNumLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        //如果没有这句，cell的自适应高度不准确。
        self.layoutSubviews()
    }
    
    //设置contentLabel：标题的字号比内容大一些
    func setContentLabel(content:String) -> NSAttributedString{
        let mString = NSMutableAttributedString(string: content)
        if mString.length > 0{
            let paragraphArray = mString.string.components(separatedBy: "\n")
            //获取第一段
            var firstPara = paragraphArray.first!
            print("firstPara:\(firstPara)")
            if firstPara.count == 0{
                firstPara = " "
            }
            //第一段的字体大小：16，内容的字体大小：14
            //1、标题格式
            let titleAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.init(name: userDefaultManager.fontName, size: 17)!,
            ]
            let titleRange = NSRange(location: 0, length: firstPara.count)
            mString.addAttributes(titleAttributes, range: titleRange)
            //2、内容格式
            let contentAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.init(name: userDefaultManager.fontName, size: 14)!,
            ]
            let contentRange = NSRange(location: firstPara.count, length: mString.length - firstPara.count)
            mString.addAttributes(contentAttributes, range: contentRange)
            return mString
        }else{
            return mString
        }
    }
    
}

