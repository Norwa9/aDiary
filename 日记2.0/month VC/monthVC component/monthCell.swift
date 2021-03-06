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
            contentLabel.text = text
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
        globalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func globalSetup() {
        setupContainerView()
        setupContentLabels()
    }
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 5).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -5).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 95.0).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 384).isActive = true//限制住contentView的宽度，使之能够在高度根据contentLabel自适应
        
        //custom containerView
//        containerView.layer.borderWidth = 1
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 10
        containerView.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        
    }
    
    private func setupContentLabels() {
        //contentLabel
        contentLabel.numberOfLines = 0
        containerView.addSubview(contentLabel)
        contentLabel.font = UIFont(name: "Noto Sans S Chinese", size: 14)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        //tags Label
        containerView.addSubview(tagsLabel)
        tagsLabel.numberOfLines = 0
        tagsLabel.font = UIFont(name: "Noto Sans S Chinese", size: 11)
        tagsLabel.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        //data Label
        containerView.addSubview(dateLabel)
        dateLabel.font = UIFont(name: "Noto Sans S Chinese", size: 11)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        //word Number Label
        containerView.addSubview(wordNumLabel)
        wordNumLabel.textAlignment = .right
        wordNumLabel.font = UIFont(name: "Noto Sans S Chinese", size: 11)
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
            contentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.0),
            contentLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 150),
            contentLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -25.0),
            
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
    
}
