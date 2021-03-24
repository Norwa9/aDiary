//
//  todayVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import JXPhotoBrowser

class todayVC: UIViewController {
    var todayDiary:diaryInfo!
    
    weak var topbar:topbarView!
    
    lazy var tagsViewController:tagsView = {
        //配置tagsView
        let tagsViewController = tagsView()
        tagsViewController.transitioningDelegate = self
        tagsViewController.modalPresentationStyle = .custom//模态
        return tagsViewController
    }()
    
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
        //tap on self.view
        let tapEnterTextView = UITapGestureRecognizer(target: self, action: #selector(enterEditingTextView))
        view.addGestureRecognizer(tapEnterTextView)
        //tap on image
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        textView.addGestureRecognizer(tap)
        
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
            //传递当前的diary
            tagsViewController.diary = todayDiary
            //call viewDidLoad()
            self.present(tagsViewController, animated: true, completion: nil)
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
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyBoardToolsBar.frame.height * 2, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset//确保滑动条跟scrollview内容保持一致
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
}
extension todayVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        print("scroll view content off set : \(y)")
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

extension todayVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func importPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        insertPictureToTextView(image: image)
        dismiss(animated: true)
    }
    
    func insertPictureToTextView(image:UIImage){
        //创建附件
        let attachment = NSTextAttachment()
        //设置附件的大小
        let imageAspectRatio = image.size.height / image.size.width
        let peddingX:CGFloat =  0
        let width = textView.frame.width - 2 * peddingX
        let height = width * imageAspectRatio
        //设置照片附件
        let imageData = image.jpegData(compressionQuality: 0.2)
        let image = UIImage(data: imageData!)!.compressPic(toSize: CGSize(width: width, height: height))
        attachment.image = image
//        attachment.image = image.compressPic(toSize: CGSize(width: width, height: height))
        attachment.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        print("insert,bounds:\(attachment.bounds)")
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
    
    private func prepareTextImages(aString:NSAttributedString,returnCleanText:Bool = false) -> NSMutableAttributedString {
        let cleanText = NSMutableAttributedString(attributedString: aString)
        let mutableText = NSMutableAttributedString(attributedString: aString)
        let width = self.textView.frame.width
        let bounds = self.textView.bounds
        mutableText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: mutableText.length), options: [], using: { [width] (object, range, pointer) in
            let textViewAsAny: Any = self.textView!
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: textViewAsAny as? NSTextContainer, characterIndex: range.location){
                
                cleanText.replaceCharacters(in: range, with: "P")
                
                let aspect = img.size.width / img.size.height
                if img.size.width <= width {
                    attachment.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                    print("img.size.width <= width,bounds:\(attachment.bounds)")
                    return 
                }
                let height = width / aspect
                attachment.bounds = CGRect(x: 0, y: 0, width: width, height: height)
//                print("bounds:\(attachment.bounds)")
                
            }
            })
        
        if returnCleanText{
            return cleanText
        }else{
            return mutableText
        }
        
    }
}

//MARK:-UITextViewDelegate
extension todayVC:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        //关闭左右滑动
        let customPageVC = UIApplication.getcustomPageViewController()
        customPageVC.pageScrollView.isScrollEnabled = false
        
        //如果日记为空，清除placeholder，开始输入
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
    }
    

    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        
        //开启左右滑动
        let customPageVC = UIApplication.getcustomPageViewController()
        customPageVC.pageScrollView.isScrollEnabled = true
        
        if textView.text != ""{
            //存储纯文本
            let string = prepareTextImages(aString: textView.attributedText, returnCleanText: true).string
            todayDiary.content = string.replacingOccurrences(of: "P\\b", with: "[图片]",options: .regularExpression)
            //存储富文本
            saveAttributedString(date_string: todayDiary.date!, aString: textView.attributedText)
            DataContainerSingleton.sharedDataContainer.diaryDict[todayDiary.date!] = todayDiary
            
            //更新monthVC的UI
            let monthVC = UIApplication.getMonthVC()
            monthVC.collectionView.performBatchUpdates({
                                let indexSet = IndexSet(integersIn: 0...0)
                                monthVC.collectionView.reloadSections(indexSet)
                            }, completion: nil)
        }
    }
    
    @objc func enterEditingTextView(){
        textView.becomeFirstResponder()
        //定位到文字最末端
        textView.selectedRange = NSMakeRange(textView.text.count, 0)
    }
    
    //MARK:-富文本图片点击
    @objc func tapOnImage(_ sender: UITapGestureRecognizer){
        //参考自：https://stackoverflow.com/questions/48498366/detect-tap-on-images-attached-in-nsattributedstring-while-uitextview-editing-is
        guard let textView = sender.view as? UITextView else{
            return
        }
        let layoutManager = textView.layoutManager
        var location = sender.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        //推算触摸点处的字符下标
        let characterIndex = layoutManager.characterIndex(
            for: location,
            in: textView.textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < textView.textStorage.length{
            //识别字符下标characterIndex处的富文本信息
            let attachment = textView.attributedText.attribute(NSAttributedString.Key.attachment,
                                                               at: characterIndex,
                                                               effectiveRange: nil) as? NSTextAttachment
            //1.字符下标characterIndex处为图片附件，则展示它
            if let attachment = attachment{
                textView.resignFirstResponder()
                //获取image
                guard let attachImage = attachment.image(forBounds: textView.bounds, textContainer: textView.textContainer, characterIndex: characterIndex)else{
                    print("无法获取image")
                    return
                }
                
                //展示image
                let browser = JXPhotoBrowser()
                browser.numberOfItems = {
                    1
                }
                browser.reloadCellAtIndex = { context in
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    browserCell?.imageView.image = attachImage
                }
                browser.show()
            //2.字符下标characterIndex处为字符，则将光标移到触摸的字符下标
            }else{
                textView.becomeFirstResponder()
                textView.selectedRange = NSMakeRange(characterIndex, 0)
            }
        }
    }
}

//MARK:-生命周期
extension todayVC{
    //读入选中的日记
    func loadTodayData(){
        todayDiary = DataContainerSingleton.sharedDataContainer.selectedDiary
        //load pictures
        photoImages.removeAll()
        for uuid in todayDiary.uuidofPictures {
            let path = getDocumentsDirectory().appendingPathComponent(uuid)
            photoImages.append(UIImage(contentsOfFile: path.path)!)
        }
        
        //load textView
        if todayDiary.content.count == 0{
            //palce holder
            textView.text = "今天发生了什么..."
            textView.textColor = UIColor.lightGray
        }else{
            textView.text = todayDiary.content
            textView.textColor = UIColor.black
            if let aString = loadAttributedString(date_string: todayDiary.date!){
                    let preparedText = prepareTextImages(aString: aString)
                    textView.attributedText = preparedText
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
        topbar.button2.buttonImageView.image = UIImage(named: todayDiary.mood.rawValue)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        
        configureTopbar()
        configurePhotosCollectionView()
        configureTodayView()
        loadTodayData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //获取欲展示的日记
        loadTodayData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("todayVC viewDidDisappear")
        if textView.textColor == UIColor.lightGray{
            return
        }
        textView.text = nil
        textView.attributedText = nil
    }
}
