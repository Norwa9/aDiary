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
    //static let KphotoHeight:CGFloat = 150
    var hasSelected:Bool = false
    
    static let reusableID = "monthCell"
    private var containerView = UIView()
    var emojisLabel:UILabel = UILabel()
    var titleLabel:UILabel = UILabel()
    var splitLine:UIView = UIView()//标题下的分割线
    var contentLabel:UILabel = UILabel()
    var dateLabel:UILabel = UILabel()
    var tagsLabel:TagListView = TagListView()
    var albumView:UICollectionView!
    var todoListView:TodoListView!
    var photos:[UIImage] = [UIImage]()
    var diary:diaryInfo!
    
    var albumViewLayout:AlbumViewLayout!
    
    var tags:[String]!{
        didSet{
            self.tagsLabel.removeAllTags()
            self.tagsLabel.addTags(tags)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:-UI界面搭建
    private func initUI(){
        contentView.addSubview(containerView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        //contentView
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.setupShadow(opacity: 1, radius: 2, offset: .zero, color: UIColor.black.withAlphaComponent(0.35))
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        
        //containerView
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 10
        
        self.layoutSubviews()
        
        //titleLabel
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //分隔线
        splitLine.backgroundColor = UIColor.colorWithHex(hexColor: 0xF1F1F1)
        splitLine.layer.cornerRadius = 2
        splitLine.translatesAutoresizingMaskIntoConstraints = false
        
        //albumView
        albumViewLayout = AlbumViewLayout()
        albumView = UICollectionView(frame: .zero, collectionViewLayout: albumViewLayout)
        albumView.delegate = self
        albumView.dataSource = self
        albumView.isScrollEnabled = true
        albumView.showsHorizontalScrollIndicator = false
        albumView.register(photoCell.self, forCellWithReuseIdentifier: photoCell.photoCellID)
        albumView.translatesAutoresizingMaskIntoConstraints = false
        albumView.backgroundColor = .clear
        albumView.layer.cornerRadius = 10
        
        //contentLabel
        //字号14
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.clipsToBounds = true
        contentLabel.textColor = UIColor.colorWithHex(hexColor: 0x5D5E61)//石岩灰
        //contentLabel.layer.cornerRadius = 5
        //contentLabel.backgroundColor = APP_GRAY_COLOR().withAlphaComponent(0.7)
        
        //tags Label
        tagsLabel.textFont = UIFont(name: "DIN Alternate", size: 14)!
        tagsLabel.alignment = .left
        tagsLabel.tagBackgroundColor = .systemGray6
        tagsLabel.cornerRadius = 5
        tagsLabel.textColor = .gray
        tagsLabel.clipsToBounds = true
        tagsLabel.isUserInteractionEnabled = false
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //data Label
        dateLabel.font = UIFont(name: "DIN Alternate", size: 20)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //todo-list
        todoListView = TodoListView(frame: .zero)
        
        //emojisLabel
        emojisLabel.font = UIFont(name: "Apple color emoji", size: 20)
        
        
        containerView.addSubview(emojisLabel)
        containerView.addSubview(albumView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(splitLine)
        containerView.addSubview(contentLabel)
        containerView.addSubview(tagsLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(todoListView)
    }
    
    //MARK:-Auto layout
    private func setupConstraints() {
        containerView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.equalTo(layoutParasManager.shared.monthCellWidth)//必须限制住contentView的宽度，否者contentView的宽度错乱
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(containerView).offset(2)
            make.centerX.equalToSuperview()
        }
        
        emojisLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emojisLabel.snp.bottom).offset(2)
            make.left.equalTo(containerView).offset(15)
            make.right.equalTo(containerView).offset(-15)
        }
        
        splitLine.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel).offset(-3)
            make.right.equalTo(titleLabel).offset(3)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.height.equalTo(1)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(splitLine.snp.bottom).offset(2)
            make.height.lessThanOrEqualTo(200)
        }
        
        albumView.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(2)
            make.left.equalTo(containerView)
            make.right.equalTo(containerView)
            make.height.equalTo(0)
        }
        
        todoListView.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(10)
            make.right.equalTo(containerView).offset(-10)
            make.top.equalTo(albumView.snp.bottom).offset(5)
            make.height.equalTo(100)
        }
        
        tagsLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(todoListView.snp.bottom).offset(5)
            make.left.equalTo(containerView).offset(15)
            make.right.equalTo(containerView).offset(-15)
            make.bottom.equalTo(containerView.snp.bottom).offset(-5)
        }
   
    }
    
    //MARK:-设置Model
    func setViewModel(_ diary:diaryInfo){
        self.diary = diary
        self.updateUI()//获取viewModel后需要更新UI
    }
    
    func updateUI(){
        updateCons()
        setTodayPropmt()
        
        self.emojisLabel.attributedText = diary.emojis.joined().changeWorldSpace(space: -7)
        self.titleLabel.attributedText = diary.content.getAttrTitle()
        self.contentLabel.attributedText = diary.content.getAttrContent()
        self.tags = diary.tags
        self.dateLabel.text = "\(diary.day)号 \(diary.weekDay)"
        self.fillImages(diary: diary)
        
        self.todoListView.setViewModel(diary)
    }
    
    //读取日记的所有图片
    private func fillImages(diary:diaryInfo){
        let iM = imageManager(diary: diary)
        let contains = diary.containsImage
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
                self.albumViewLayout.itemNum = images.count
                self.albumView.reloadData()
                self.albumView.layoutIfNeeded()
                self.albumView.fadeIn()//渐显动画
            }else{
                //self.row表示是当前点击的cell
                print("diary.date:\(diary.date) != self.diary.date:\(self.diary.date)")
            }
        }
    }
    
    ///设置今日提示
    private func setTodayPropmt(){
        if diary.date == GetTodayDate(){
            self.containerView.layer.borderWidth = 2;
            self.containerView.layer.borderColor = APP_GREEN_COLOR().cgColor
        }else{
            self.containerView.layer.borderWidth = 0;
        }
    }
}
//MARK:-reuse
extension monthCell{
    override func prepareForReuse() {
        super.prepareForReuse()
        self.todoListView.todos = []
        self.emojisLabel.text = ""
    }
}

//MARK:-更新约束
extension monthCell{
    ///更新约束
    func updateCons(){
        //计算包含todoListView的正确高度
        if let diary = self.diary{
            //取得todoListView的高度
            self.todoListView.snp.updateConstraints { (make) in
                make.height.equalTo(diary.calculateTodosContentHeihgt())
            }
        }
        //刷新todoListCell的样式，将会触发其updateCons()
        self.todoListView.collectionView.performBatchUpdates({
            self.todoListView.collectionView.reloadData()//使用performBatchUpdates可以防止刷新时“闪一下”
        }, completion: nil)
        
        let contains = diary.containsImage
        self.albumView.snp.updateConstraints { (make) in
            make.height.equalTo(contains ? layoutParasManager.shared.albumViewHeight : 0)
        }
        
        //瀑布流切换时
        self.containerView.snp.updateConstraints { (update) in
            update.width.equalTo(layoutParasManager.shared.monthCellWidth)
        }
        switch layoutParasManager.shared.collectioncolumnNumber {
        case 1:
            self.contentLabel.snp.updateConstraints { update in
                update.height.lessThanOrEqualTo(200)//恢复内容高度
            }
        case 2:
            self.contentLabel.snp.updateConstraints { update in
                update.height.lessThanOrEqualTo(0)//内容高度=0
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
            self.containerView.backgroundColor = .systemGray6
        } completion: { (_) in
            self.containerView.backgroundColor = .white
        }


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
