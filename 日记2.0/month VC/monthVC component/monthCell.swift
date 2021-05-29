//
//  monthCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import UIKit
import SnapKit

class monthCell: UICollectionViewCell {
    let cellPedding:CGFloat = 15//cell距离tableView两边的留白
    static let KphotoHeight:CGFloat = 150
    var hasSelected:Bool = false
    
    static let reusableID = "monthCell"
    private lazy var containerView = UIView()
    lazy var titleLabel:UILabel = UILabel()
    lazy var contentLabel:UILabel = UILabel()
    lazy var dateLabel:UILabel = UILabel()
    lazy var tagsLabel:UILabel = UILabel()
    lazy var moodImageView:UIImageView = UIImageView()
    lazy var islikeImageView:UIImageView = UIImageView()
    lazy var wordNumLabel:UILabel = UILabel()
    var albumView:UICollectionView!
    private lazy var layout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection  = .horizontal
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: monthCell.KphotoHeight, height: monthCell.KphotoHeight)
        return layout
    }()
    var photos:[UIImage] = [UIImage]()
    
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
        //对可重用的cell进行一些通用的初始化：例如阴影，圆角，约束等等。
        setupContainerView()
        setupSubviews()
    }
    
    
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
//        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 95.0).isActive = true
        let KcontainerViewW = UIScreen.main.bounds.width - 2 * cellPedding
        containerView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(5)
            make.right.equalTo(contentView).offset(-5)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.equalTo(KcontainerViewW)//限制住contentView的宽度，使之能够在高度根据contentLabel自适应s
        }
        
        containerView.layer.borderColor = APP_GREEN_COLOR().cgColor
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 10
        containerView.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        self.layoutSubviews()
        
    }
    
    
    private func setupSubviews() {
        //titleLabel
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //collectionView
        albumView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        containerView.addSubview(albumView)
        albumView.collectionViewLayout = layout
        albumView.delegate = self
        albumView.dataSource = self
        albumView.isScrollEnabled = true
        albumView.showsHorizontalScrollIndicator = false
        albumView.register(photoCell.self, forCellWithReuseIdentifier: photoCell.photoCellID)
        albumView.translatesAutoresizingMaskIntoConstraints = false
        
        albumView.backgroundColor = .clear
        albumView.layer.cornerRadius = 10
        
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
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(15)
            make.right.equalTo(containerView).offset(-15)
            make.top.equalTo(containerView).offset(8)
            make.height.equalTo(25)
        }
        
        albumView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(monthCell.KphotoHeight)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(albumView.snp.bottom).offset(2)
            make.height.lessThanOrEqualTo(200)
        }
        
        tagsLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(contentLabel.snp.bottom).offset(5)
            make.left.equalTo(contentLabel)
            make.right.equalTo(containerView).offset(-15)
            make.height.lessThanOrEqualTo(40)
            make.bottom.equalTo(dateLabel.snp.top).offset(-5)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(15)
            make.height.equalTo(20)
            make.width.equalTo(130)
            make.bottom.equalTo(containerView).offset(-5)
        }
        moodImageView.snp.makeConstraints { (make) in
            make.right.equalTo(containerView).offset(-15)
            make.centerY.equalTo(dateLabel)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        islikeImageView.snp.makeConstraints { (make) in
            make.right.equalTo(moodImageView.snp.left).offset(-5)
            make.centerY.equalTo(moodImageView)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        wordNumLabel.snp.makeConstraints { (make) in
            make.right.equalTo(islikeImageView.snp.left).offset(-5)
            make.height.equalTo(20)
            make.width.equalTo(50)
            make.centerY.equalTo(moodImageView)
        }
    }
    
    //提供计算后的cell size
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
        //这里需要 layoutIfNeeded 一下，拿到contentSize
        //参考自：https://blog.csdn.net/ssy0082/article/details/81711240
        self.layoutIfNeeded()
        
        self.titleLabel.attributedText = getAttrTitle(content: diary.content)
        self.contentLabel.attributedText = getAttrContent(content: diary.content)
//        self.contentLabel.text = diary.content
        self.tags = diary.tags
        self.dateLabel.text = diary.date! + "，" + Date().getWeekday(dateString: diary.date!)
        self.wordNum = diary.content.count
        self.isLike = diary.islike
        self.moodType = diary.mood
        self.fillImages(diary: diary)
    }
    
    //读取日记的所有图片
    func fillImages(diary:diaryInfo){
        let iM = imageManager(diary: diary)
        var contains = false
        if let flag = diary.containsImage{
            contains = flag
        }else{
            contains = iM.checkifcontainsImage()
        }
        
        self.albumView.snp.updateConstraints { (make) in
            make.height.equalTo(contains ? monthCell.KphotoHeight : 0)
        }
        if !contains{
            return
        }
        self.layoutSubviews()
        
        DispatchQueue.global(qos: .default).async {
            let images = iM.extractImages()
            DispatchQueue.main.async {
                self.photos = images
                self.albumView.reloadData()
            }
        }
    }
    
    func getAttrTitle(content:String)->NSAttributedString{
        let mContent = NSMutableAttributedString(string: content)
        if mContent.length > 0{
            //获取第一段
            let paragraphArray = content.components(separatedBy: "\n")
            let firstPara = paragraphArray.first!
            //标题的字体大小16行间距6。
            //标题格式
            let titlePara = NSMutableParagraphStyle()
            titlePara.lineSpacing = 5
            let titleAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 17, weight: .medium),
                .paragraphStyle:titlePara,
            ]
            
            let titleRange = NSMakeRange(0, firstPara.utf16.count)
            mContent.addAttributes(titleAttributes, range: titleRange)
            return mContent.attributedSubstring(from: titleRange)
        }else{
            return mContent
        }
    }
    
    func getAttrContent(content:String) -> NSAttributedString{
        let mString = NSMutableAttributedString(string: content)
        if mString.length > 0{
            //内容段样式
            let contentPara = NSMutableParagraphStyle()
            contentPara.lineSpacing = 3
            let contentAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14, weight: .regular),
                .paragraphStyle:contentPara,
            ]
            mString.addAttributes(contentAttributes, range: NSRange(location: 0, length: mString.length))
            //获取第一段Range
            let paragraphArray = content.components(separatedBy: "\n")
            let firstPara = paragraphArray.first!
            //如果日记只有一行，那么这一行的末尾是不带有"\n"的！！
            let titleLength = paragraphArray.count > 1 ? firstPara.utf16.count + 1 : firstPara.utf16.count
            let titleRange = NSMakeRange(0, titleLength)
            mString.replaceCharacters(in: titleRange, with: "")
            return mString
        }
        return mString
    }
    
    func showSelectionPrompt(){
        UIView.animate(withDuration: 0.2) {
            self.containerView.backgroundColor = APP_GRAY_COLOR()
        } completion: { (_) in
            self.containerView.backgroundColor = .white
        }


    }
    
}

extension monthCell:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumView.dequeueReusableCell(withReuseIdentifier: photoCell.photoCellID, for: indexPath) as! photoCell
        let row = indexPath.item
        cell.photo = photos[row]
        return cell
    }
    
    
}

