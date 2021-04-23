//
//  monthCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import UIKit

class monthCell: UICollectionViewCell {
    let cellPedding:CGFloat = 15//cell距离tableView两边的留白
    
    static let reusableID = "monthCell"
    private lazy var containerView = UIView()
    var contentLabel:UILabel = UILabel()
    
    var dateLabel:UILabel = UILabel()
    var tagsLabel:UILabel = UILabel()
    var moodImageView:UIImageView = UIImageView()
    var islikeImageView:UIImageView = UIImageView()
    var wordNumLabel:UILabel = UILabel()
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
            let smallsize = islikeImageView.bounds.size
            if isLike{
                self.islikeImageView.image = #imageLiteral(resourceName: "star2").compressPic(toSize: smallsize)
            }else{
                self.islikeImageView.image = #imageLiteral(resourceName: "star1").compressPic(toSize: smallsize)
            }
        }
    }
    var moodType:moodTypes!{
        didSet{
            //缩放image，防止锯齿问题。
            let smallsize = moodImageView.bounds.size
            moodImageView.image = UIImage(named: moodType.rawValue)?.compressPic(toSize: smallsize)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 5).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -5).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
//        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 95.0).isActive = true
        //限制住contentView的宽度，使之能够在高度根据contentLabel自适应
//        print("UIScreen.main.bounds.width:\(UIScreen.main.bounds.width)")
//        print("widthAnchor:\(UIScreen.main.bounds.width - 2 * cellPedding)")
        containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 2 * cellPedding).isActive = true
        self.layoutSubviews()
        //custom containerView
//        containerView.layer.borderWidth = 1
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 10
        containerView.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        
    }
    
    private func setupContentLabelsConstraints() {
        //contentLabel
        contentLabel.numberOfLines = 0
        containerView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //tags Label
        containerView.addSubview(tagsLabel)
        tagsLabel.numberOfLines = 0
        tagsLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        tagsLabel.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        //data Label
        containerView.addSubview(dateLabel)
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        //word Number Label
        containerView.addSubview(wordNumLabel)
        wordNumLabel.textAlignment = .right
        wordNumLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
//        wordNumLabel.textColor = .lightGray
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
            contentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
            contentLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            contentLabel.bottomAnchor.constraint(equalTo: tagsLabel.topAnchor, constant: -5.0),
            
            //tags Label
            tagsLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            tagsLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 40),
            tagsLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -5),
            
            //date Label
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15.0),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            dateLabel.widthAnchor.constraint(equalToConstant: 130),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            
            //moodImageView
            moodImageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
//            moodImageView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            moodImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            moodImageView.heightAnchor.constraint(equalToConstant: 20),
            moodImageView.widthAnchor.constraint(equalToConstant: 20),
            
            //islikeImageView
            islikeImageView.trailingAnchor.constraint(equalTo: moodImageView.leadingAnchor, constant: -5),
//            islikeImageView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            islikeImageView.centerYAnchor.constraint(equalTo: moodImageView.centerYAnchor),
            islikeImageView.heightAnchor.constraint(equalToConstant: 20),
            islikeImageView.widthAnchor.constraint(equalToConstant: 20),
            
            //word Number Label
            wordNumLabel.trailingAnchor.constraint(equalTo: islikeImageView.leadingAnchor, constant: -5),
            wordNumLabel.heightAnchor.constraint(equalToConstant: 20),
            wordNumLabel.widthAnchor.constraint(equalToConstant: 50),
//            wordNumLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            wordNumLabel.centerYAnchor.constraint(equalTo: moodImageView.centerYAnchor),
            
        ])
        
        
        
    }
    
    //self-sizeing所必须实现的：提供计算后的cell size
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = size.height
        newFrame.size.width = size.width
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
//        tagsLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
//        dateLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
//        wordNumLabel.font = UIFont(name: userDefaultManager.fontName, size: 11)
        //如果没有这句，cell的自适应高度不准确。
        self.layoutSubviews()
    }
    
    //设置contentLabel：标题的字号比内容大一些
    func setContentLabel(content:String) -> NSAttributedString{
        let mString = NSMutableAttributedString(string: content)
        if mString.length > 0{
            let contentPara = NSMutableParagraphStyle()
            contentPara.lineSpacing = 3
            let contentAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14, weight: .regular),
                .paragraphStyle:contentPara,
            ]
            let contentRange = NSRange(location: 0, length: mString.length)
            mString.addAttributes(contentAttributes, range: contentRange)
            
            let paragraphArray = content.components(separatedBy: "\n")
            //获取第一段
            var firstPara = paragraphArray.first!
            if firstPara.count == 0{
                firstPara = " "
            }
//            print("第一段:\(firstPara),字数:\(firstPara.count)")
            //标题的字体大小16行间距6。
            //内容的字体大小14行间距3.
            //1、标题格式
            let titlePara = NSMutableParagraphStyle()
            titlePara.lineSpacing = 5
            let titleAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 17, weight: .medium),
                .paragraphStyle:titlePara,
            ]
            
            let titleRange = NSMakeRange(0, firstPara.utf16.count)
            mString.addAttributes(titleAttributes, range: titleRange)
            return mString
        }else{
            return mString
        }
    }
    
}

