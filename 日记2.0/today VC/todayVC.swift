//
//  todayVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

class todayVC: UIViewController {
    var todayDiary:diaryInfo!
    
    weak var topbar:topbarView!
    
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var photosView:UIView!
    @IBOutlet weak var photosCollectionView:UICollectionView!
    var flowLayout: UICollectionViewFlowLayout! {
        return photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var curPhotoIndexLabel:UILabel!
    @IBOutlet weak var textView:UITextView!
    var keyBoardToolsBar:toolsBar!
    var keyBoardToolsBarFrame:CGRect!
    @IBOutlet weak var photosViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    
    var isPhotosViewHidding:Bool = true
    
    var photoImages = [UIImage]()
    
    func configureTodayView(){
        //textView
        textView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(enterEditingTextView))
        view.addGestureRecognizer(tap)
        
        //tools bar
        keyBoardToolsBar = toolsBar(frame: CGRect(x: 0, y: 900, width: 414, height: 40))
        keyBoardToolsBarFrame = keyBoardToolsBar.frame
        keyBoardToolsBar.textView = textView
        keyBoardToolsBar.todayVC = self
        self.view.addSubview(keyBoardToolsBar)
        keyBoardToolsBar.alpha = 0
    }
    
    func configureTopbar(){
        //初始情况下隐藏照片集合
        self.photosViewTopConstraint.constant = -self.photosView.frame.height
        self.textViewTopConstraint.constant = 0
        
        //通知中心：响应button，响应键盘
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(todayButtonsTapped(sender:)), name: NSNotification.Name("todayButtonsTapped"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification,object: nil,queue: nil){ [self](note: Notification!) -> Void in
//            print("todayVC进入后台了")
//            saveAttributedString(date_string: todayDiary.date!, aString: textView.attributedText)
//        }
//        notificationCenter.addObserver(self, selector: #selector(),name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    func configurePhotosCollectionView(){
        //register photo cell
        let collectionCellNib = UINib(nibName: photoCell.reusableId, bundle: Bundle.main)
        photosCollectionView.register(collectionCellNib, forCellWithReuseIdentifier: photoCell.reusableId)
        
        //set delegate
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        //set collection layout
        let pedding:CGFloat = 20
        let cellHeight = photosCollectionView.frame.height - 2 * pedding
        let cellWidth = cellHeight * (3/4)
        flowLayout.itemSize = CGSize(width: cellWidth , height: cellHeight)
        flowLayout.minimumLineSpacing = 30
        flowLayout.minimumInteritemSpacing = 20
        
        //set collecionView inset
        let insetX = (photosView.bounds.width - flowLayout.itemSize.width) / 2.0
        photosCollectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        
        
    }
    
    @objc func todayButtonsTapped(sender: NSNotification){
        print("todayButtonsTapped")
        guard let button = sender.userInfo!["buttonTag"] as? topbarButton else{return}
        switch button.tag {
        case 1:
            button.islike.toggle()
            todayDiary.islike = button.islike
            break
        case 2,3:
            let vc = tagsView()
            //配置tagsView
            vc.diary = todayDiary
            
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom//模态
            self.present(vc, animated: true, completion: nil)
            break
        default:
            return
        }
    }
    
    
    
    func animatePhothsView(isHide:Bool){
        if isHide{
            isPhotosViewHidding = false
            self.photosViewTopConstraint.constant = 0
            self.textViewTopConstraint.constant = 385
        }else{
            isPhotosViewHidding = true
            scrollView.bounces = true
            self.photosViewTopConstraint.constant = -self.photosView.frame.height
            self.textViewTopConstraint.constant = 0
            
        }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)//从screen坐标系转换为当前view坐标系
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            //键盘隐藏
            let x = keyBoardToolsBarFrame.origin.x
            let y = keyBoardToolsBarFrame.origin.y
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)//自带动画效果
            keyBoardToolsBar.alpha = 0
            scrollView.contentInset = .zero//键盘消失，文本框视图的缩进为0，与当前view的大小一致
        } else {
            //键盘出现
            let x = keyBoardToolsBarFrame.origin.x
            let y = keyboardScreenEndFrame.origin.y - keyBoardToolsBarFrame.size.height - topbar.frame.height - 4//4是screen坐标系转换到view坐标系产生的误差
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)
//            print("keyBoardToolsBar.frame:\(keyBoardToolsBar.frame)")
//            print("keyboardViewEndFrame:\(keyboardViewEndFrame)")
            keyBoardToolsBar.alpha = 1
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyBoardToolsBar.frame.height, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset//确保滑动条跟scrollview内容保持一致
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
}
extension todayVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y < -150{
            if isPhotosViewHidding{
//                animatePhothsView(isHide: isPhotosViewHidding)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //确保是collectionView响应
        guard let scrollView = scrollView as? UICollectionView else{
            return
        }
        
        let layout = self.photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)//四舍五入
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        targetContentOffset.pointee = offset
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //确保是collectionView响应
        guard let scrollView = scrollView as? UICollectionView else{
            return
        }
        let layout = self.photosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        let offsetX = scrollView.contentOffset.x
        let index = (offsetX + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)//四舍五入
        
        //更新curPhotoIndexLabel
        let curPhotoIndex = abs(Int(roundedIndex)) + 1
        curPhotoIndexLabel.text = "\(curPhotoIndex)/\(photoImages.count)"
    }

    
}

extension todayVC:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        curPhotoIndexLabel.text = "1/\(photoImages.count)"
        return photoImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCell.reusableId, for: indexPath) as! photoCell
        let index = indexPath.item
        
        cell.photoImageView.image = photoImages[index]
        return cell
    }
}

extension todayVC:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return tagsVC(presentedViewController: presented, presenting: presenting)
    }
}

extension todayVC:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        //如果日记为空，清除placeholder，开始输入
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        todayDiary.content = textView.text
        saveAttributedString(date_string: todayDiary.date!, aString: textView.attributedText)
    }
    
    @objc func enterEditingTextView(){
        textView.becomeFirstResponder()
    }
}

extension todayVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        insertPictureToTextView(image: image)
        dismiss(animated: true)
    }
    
    func insertPictureToTextView(image:UIImage){
        //创建附件
        let attachment = NSTextAttachment()
        //设置附件的大小
        let imageAspectRatio = image.size.height / image.size.width
        let peddingX:CGFloat =  0
        let imageWidth = textView.frame.width - 2 * peddingX
        let imageHeight = imageWidth * imageAspectRatio
        //设置照片附件
//        let compressedImage = image.compressPic(toSize: CGSize(width: imageWidth, height: imageHeight))
//        let compressedImage = image
//        attachment.image = compressedImage
        attachment.image = UIImage(data: image.jpegData(compressionQuality: 0.5)!)
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: imageWidth,
                                   height: imageHeight)
        //将附件转成NSAttributedString类型的属性化文本
        let attStr = NSAttributedString(attachment: attachment)
        //获取textView的所有文本，转成可变的文本
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        //获得目前光标的位置
        let selectedRange = textView.selectedRange
        //插入附件
        mutableStr.insert(attStr, at: selectedRange.location)
        mutableStr.insert(NSAttributedString(string: "\n"), at: selectedRange.location+1)
        //格式化mutableStr
        mutableStr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Noto Sans S Chinese", size: 20)!, range: NSMakeRange(0,mutableStr.length))
        textView.attributedText = mutableStr
    }
    
    private func prepareTextImages(aString:NSAttributedString) -> NSMutableAttributedString {
        let mutableText = NSMutableAttributedString(attributedString: aString)
        let width  = self.textView.frame.width
        mutableText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: mutableText.length), options: [], using: { [width] (object, range, pointer) in
            let textViewAsAny: Any = self.textView!
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: self.textView.bounds, textContainer: textViewAsAny as? NSTextContainer, characterIndex: range.location){
                let aspect = img.size.width / img.size.height
                if img.size.width <= width {
                    attachment.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                    return
                }
                let height = width / aspect
                attachment.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            }
            })
        return mutableText
    }
}

extension todayVC{
    //MARK:-生命周期
    //读入选中的日记
    func configureTodayData(){
        todayDiary = DataContainerSingleton.sharedDataContainer.selectedDiary
        
        //load pictures
        for uuid in todayDiary.uuidofPictures {
            let path = getDocumentsDirectory().appendingPathComponent(uuid)
            photoImages.append(UIImage(contentsOfFile: path.path)!)
        }
        
        //load txt
        if todayDiary.content.count == 0{
            //palce holder
            textView.text = "今天发生了什么..."
            textView.textColor = UIColor.lightGray
        }else{
            textView.text = todayDiary.content
            textView.textColor = UIColor.black
            if let aString = loadAttributedString(date_string: todayDiary.date!){
                textView.attributedText = prepareTextImages(aString: aString)
            }
            
        }
        
        //load ohter info
        topbar.dataLable1.text = todayDiary.date
        topbar.dataLable2.text = getWeekDayFromDateString(string: todayDiary.date!)
        if todayDiary.date == getTodayDate(){
            topbar.dataLable2.text! += "*"
        }
        topbar.dataLable1.sizeToFit()
        
        topbar.button1.islike = todayDiary.islike
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        
        configureTopbar()
        configurePhotosCollectionView()
        configureTodayView()
        configureTodayData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //获取欲展示的日记
        configureTodayData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //更新数据库里对应的日记
        DataContainerSingleton.sharedDataContainer.diaryDict[todayDiary.date!] = todayDiary
    }
    override func viewDidDisappear(_ animated: Bool) {
        textView.attributedText = nil
    }
}
