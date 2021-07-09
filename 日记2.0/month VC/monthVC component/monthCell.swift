//
//  monthCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import UIKit
import SnapKit
import TagListView

//let kMonthCellWidth:CGFloat = UIScreen.main.bounds.width / 2

class monthCell: UICollectionViewCell {
    static let KphotoHeight:CGFloat = 150
    var hasSelected:Bool = false
    
    static let reusableID = "monthCell"
    private var containerView = UIView()
    var titleLabel:UILabel = UILabel()
    var splitLine:UIView = UIView()//标题下的分割线
    var contentLabel:UILabel = UILabel()
    var dateLabel:UILabel = UILabel()
    var tagsLabel:TagListView = TagListView()
    var moodImageView:UIImageView = UIImageView()
    var islikeImageView:UIImageView = UIImageView()
    var wordNumLabel:UILabel = UILabel()
    var albumView:UICollectionView!
    private var layout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection  = .horizontal
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: monthCell.KphotoHeight, height: monthCell.KphotoHeight)
        return layout
    }()
    var photos:[UIImage] = [UIImage]()
    var diary:diaryInfo!
    
    var tags:[String]!{
        didSet{
            self.tagsLabel.removeAllTags()
            self.tagsLabel.addTags(tags)
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
    
    private func globalSetup() {
        //对可重用的cell进行一些通用的初始化：例如阴影，圆角，约束等等。
        setupContainerView()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    let kMonthCellWidth = (UIScreen.main.bounds.width) / 2 - 15//它决定了cell的宽度
    //MARK:-UI界面搭建
    private func setupContainerView() {
        contentView.addSubview(containerView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.equalTo(layoutParasManager.shared.itemWidth)//必须限制住contentView的宽度，否者contentView的宽度错乱
        }
        
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        
        
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10
        
        self.layoutSubviews()
        
    }
    
    private func setupSubviews() {
        //titleLabel
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //分隔线
        containerView.addSubview(splitLine)
        splitLine.backgroundColor = UIColor.colorWithHex(hexColor: 0xF1F1F1)
        splitLine.layer.cornerRadius = 2
        splitLine.translatesAutoresizingMaskIntoConstraints = false
        
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
        tagsLabel.textFont = UIFont(name: "DIN Alternate", size: 10)!
        tagsLabel.alignment = .left
        tagsLabel.tagBackgroundColor = .lightGray
        tagsLabel.cornerRadius = 5
        tagsLabel.textColor = .white
        tagsLabel.clipsToBounds = true
        tagsLabel.isUserInteractionEnabled = false
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //data Label
        containerView.addSubview(dateLabel)
        dateLabel.font = UIFont(name: "DIN Alternate", size: 11)
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
        }
        
        splitLine.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel).offset(-3)
            make.right.equalTo(titleLabel).offset(3)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.height.equalTo(1)
        }
        
        albumView.snp.makeConstraints { (make) in
            make.top.equalTo(splitLine.snp.bottom).offset(2)
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
            make.right.equalTo(moodImageView.snp.left).offset(-2)
            make.centerY.equalTo(moodImageView)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        wordNumLabel.snp.makeConstraints { (make) in
            make.right.equalTo(islikeImageView.snp.left).offset(-2)
            make.height.equalTo(20)
            make.width.equalTo(50)
            make.centerY.equalTo(moodImageView)
        }
    }
    
    //MARK:-设置Model
    func fillCell(diary:diaryInfo){
        self.updateWCons()
        
        self.diary = diary
        self.titleLabel.attributedText = getAttrTitle(content: diary.content)
        self.contentLabel.attributedText = getAttrContent(content: diary.content)
        self.tags = diary.tags
        self.dateLabel.text = "\(diary.day)号，\(diary.weekDay)"
        self.wordNum = diary.content.count
        self.isLike = diary.islike
        self.moodType = moodTypes(rawValue: diary.mood)!
        self.fillImages(diary: diary)
    }
    
    //读取日记的所有图片
    func fillImages(diary:diaryInfo){
        let iM = imageManager(diary: diary)
        let contains = diary.containsImage
        
        self.albumView.snp.updateConstraints { (make) in
            make.height.equalTo(contains ? monthCell.KphotoHeight : 0)
        }
        if !contains{
            //如果没有照片，则将albumView清空，防止复用的出现在其他cell里
            self.photos.removeAll()
            self.albumView.reloadData()
            return
        }
        
        /*
         NOTE:
         由于albumView重用的缘故，异步读取所有图片的过程中，
         会显示复用的图片，数据显示混乱，
         为此，在异步读取图片之前，干脆将albumView的图片清空，这样就图片就不会显示错乱了。
         */
        self.photos.removeAll()
        self.albumView.reloadData()
        
         //异步读取图片，然后刷新albumView
        iM.extractImages { (images,diary) in
            /*
             NOTE:
             回调方法的参数images对应的是第atRow个cell的日记的图片，
             由于异步的原因，当前主线程的cell已经发生变化，因此要进行比对，如果不一致则不能装填
            */
            if diary.date == self.diary.date{
                self.photos = images
                self.albumView.reloadData()
                self.albumView.layoutIfNeeded()
                self.albumView.fadeIn()//渐显动画
            }else{
                //self.row表示是当前点击的cell
                print("diary.date:\(diary.date) != self.diary.date:\(self.diary.date)")
            }
        }
    }
    
    private func getAttrTitle(content:String)->NSAttributedString{
        let mContent = NSMutableAttributedString(string: content)
        if mContent.length > 0{
            //获取第一段
            let paragraphArray = content.components(separatedBy: "\n")
            let firstPara = paragraphArray.first!
            //标题的字体大小16行间距6。
            //标题格式
            let titlePara = NSMutableParagraphStyle()
            titlePara.lineSpacing = 3
            let titleAttributes:[NSAttributedString.Key : Any] = [
//                .font : UIFont.systemFont(ofSize: 17, weight: .medium),
                .font : UIFont(name: "DIN Alternate", size: 17)!,
                .paragraphStyle:titlePara,
            ]
            
            let titleRange = NSMakeRange(0, firstPara.utf16.count)
            mContent.addAttributes(titleAttributes, range: titleRange)
            return mContent.attributedSubstring(from: titleRange)
        }else{
            return mContent
        }
    }
    
    private func getAttrContent(content:String) -> NSAttributedString{
        let mString = NSMutableAttributedString(string: content)
        if mString.length > 0{
            //内容段样式
            let contentPara = NSMutableParagraphStyle()
            contentPara.lineSpacing = 3
            let contentAttributes:[NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14, weight: .regular),
//                .font : UIFont(name: "DIN Alternate", size: 14)!,
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
    
}
//MARK:-内嵌的Collection View
extension monthCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("dequeue photo cell")
        let cell = albumView.dequeueReusableCell(withReuseIdentifier: photoCell.photoCellID, for: indexPath) as! photoCell
        let row = indexPath.item
        cell.photo = photos[row]
        return cell
    }
    
    
}

//MARK:-瀑布流切换
extension monthCell{
    ///切换单双列展示时，更新宽度约束
    func updateWCons(){
        self.containerView.snp.updateConstraints { (update) in
            update.width.equalTo(layoutParasManager.shared.itemWidth)
        }
        switch layoutParasManager.shared.collectioncolumnNumber {
        case 1:
            self.wordNumLabel.snp.updateConstraints { (update) in
                update.width.equalTo(50)
            }
            self.moodImageView.snp.updateConstraints { (update) in
                update.right.equalTo(containerView).offset(-15)
            }
        case 2:
            self.wordNumLabel.snp.updateConstraints { (update) in
                update.width.equalTo(0)
            }
            self.moodImageView.snp.updateConstraints { (update) in
                update.right.equalTo(containerView).offset(-5)
            }
        default:
            return
        }
        
        /**
         经过非常多调试试错出来的解决方案：
         必须要setNeedsLayout和layoutIfNeeded搭配才能起到丝滑的动画过渡效果。
         setNeedsLayout相当于layoutIfNeeded的信号，没有信号layoutIfNeeded将不起作用。
         或者手动设置约束属性heightConstraint.constant = flag ? 100 : 0也可以作为layoutIfNeeded的信号
         但是这里snp.updateConstraints却好像没有给layoutIfNeeded发送信号？所以我们要事先声明setNeedsLayout
         参考：https://medium.com/@linhairui19/difference-between-setneedslayout-layoutifneeded-180a2310e2e6
         */
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}

//MARK:-选中状态
extension monthCell{
    func showSelectionPrompt(){
        UIView.animate(withDuration: 0.2) {
            self.containerView.backgroundColor = APP_GRAY_COLOR()
        } completion: { (_) in
            self.containerView.backgroundColor = .white
        }


    }
}
