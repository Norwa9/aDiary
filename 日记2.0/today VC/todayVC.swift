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
    
    @IBOutlet weak var textView:UITextView!
    var keyBoardToolsBar:toolsBar!
    var keyBoardToolsBarFrame:CGRect!
    
    var photoImages = [UIImage]()
    
    var lastDiary:String = ""
    
    func configureTodayView(){
        //textView
        textView.delegate = self
        textView.font = UIFont(name: userDefaultManager.fontName, size: userDefaultManager.fontSize)
//        textView.layoutManager.allowsNonContiguousLayout = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        textView.addGestureRecognizer(tap)
//        let mail = UIMenuItem(title:"邮件", action: #selector(mailAction))
//
//        let menu=UIMenuController()
//
//        menu.menuItems = [mail]
        
        //tools bar
        keyBoardToolsBar = toolsBar(frame: CGRect(x: 0, y: 900, width: UIScreen.main.bounds.width, height: 40))
        keyBoardToolsBarFrame = keyBoardToolsBar.frame
        keyBoardToolsBar.textView = textView
        keyBoardToolsBar.todayVC = self
        self.view.addSubview(keyBoardToolsBar)
        keyBoardToolsBar.alpha = 0
        
        
    }
    
    func configureTopbar(){
        //通知中心：响应button，响应键盘
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(todayButtonsTapped(sender:)), name: NSNotification.Name("todayButtonsTapped"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func todayButtonsTapped(sender: NSNotification){
        print("todayButtonsTapped")
        guard let button = sender.userInfo!["buttonTag"] as? topbarButton else{return}
        switch button.tag {
        case 1:
            button.islike.toggle()
            todayDiary.islike = button.islike
            let monthVC = UIApplication.getMonthVC()
            monthVC.calendar.reloadData()
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
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)//从screen坐标系转换为当前view坐标系
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            //1.键盘隐藏
            let x = keyBoardToolsBarFrame.origin.x
            let y = keyBoardToolsBarFrame.origin.y
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)//自带动画效果
            keyBoardToolsBar.alpha = 0
            textView.contentInset = .zero//键盘消失，文本框视图的缩进为0，与当前view的大小一致
        } else{
            //2.键盘出现
            let x = keyBoardToolsBarFrame.origin.x
            let y = keyboardScreenEndFrame.origin.y - keyBoardToolsBarFrame.size.height - topbar.frame.height - 4//4是screen坐标系转换到view坐标系产生的误差
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)
            keyBoardToolsBar.alpha = 1
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyBoardToolsBar.frame.height, right: 0)
        }
        
    }
    
}

//MARK:-tagsVC
extension todayVC:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return tagsVC(presentedViewController: presented, presenting: presenting)
    }
}

//MARK:-插入图片
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
        let imageAspectRatio = image.size.height / image.size.width
        let pedding:CGFloat = 10
        let imageWidth = (textView.frame.width - pedding)
        let imageHeight = (imageWidth * imageAspectRatio)
        let compressedImage = image.compressPic(toSize: CGSize(width: imageWidth * 2, height: imageHeight * 2))//修改尺寸，防止从存储中读取富文本时图片方向错位
        attachment.image = compressedImage.createRoundedRectImage(size: compressedImage.size, radius: compressedImage.size.width / 25)
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: imageWidth / userDefaultManager.imageScalingFactor,
                                   height: imageHeight / userDefaultManager.imageScalingFactor)
        
        //将附件转成NSAttributedString类型的属性化文本
        let imageAttr = NSAttributedString(attachment: attachment)
        let imageAlignmentStyle = NSMutableParagraphStyle()
        imageAlignmentStyle.alignment = .center
        imageAlignmentStyle.lineSpacing = userDefaultManager.lineSpacing
        let attributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle:imageAlignmentStyle,
        ]
        //获取textView的所有文本，转成可变的文本
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        //获得目前光标的位置
        let selectedRange = textView.selectedRange
        //居中插入图片
        let insertLoaction = selectedRange.location
        mutableStr.insert(imageAttr, at: insertLoaction)
        mutableStr.addAttributes(attributes, range: NSRange(location: insertLoaction, length: 1))
        //另起一行
        mutableStr.insert(NSAttributedString(string: "\n"), at: insertLoaction + 1)
        
        mutableStr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: userDefaultManager.fontName, size: userDefaultManager.fontSize)!, range: NSMakeRange(0,mutableStr.length))
        textView.attributedText = mutableStr
        //从插入图片的下一行继续编辑
        textView.selectedRange = NSRange(location: insertLoaction + 2, length: 0)
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    
    
    
}

//MARK:-UITextView
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
        //开启左右滑动
        let customPageVC = UIApplication.getcustomPageViewController()
        customPageVC.pageScrollView.isScrollEnabled = true
        
        //存储纯文本
        let string = textView.attributedText.processAttrString(textView: self.textView,returnCleanText: true).string
        todayDiary.content = string.replacingOccurrences(of: "P\\b", with: "[图片]",options: .regularExpression)
        //存储富文本
        saveAttributedString(date_string: todayDiary.date!, aString: textView.attributedText)
        DataContainerSingleton.sharedDataContainer.diaryDict[todayDiary.date!] = todayDiary
        
        //更新monthVC的UI
        let monthVC = UIApplication.getMonthVC()
        monthVC.reloadCollectionViewData()
        monthVC.calendar.reloadData()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //当换行时，调用addNewLine()来处理递增数字列表的任务
        if text == "\n"{
            let textFormatter = TextFormatter(textView: textView)
            textFormatter.addNewLine()
            return false
        }else{
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
            textView.typingAttributes[.paragraphStyle] = paragraphStyle
        }
        //除了换行符，其他的字符无需处理，正常输出即可
        return true//若为false，键入的新字符不会递给storage
    }

    
    //富文本图片点击
    @objc func tapOnImage(_ sender: UITapGestureRecognizer){
        print("tap on textView")
        //参考自：https://stackoverflow.com/questions/48498366/detect-tap-on-images-attached-in-nsattributedstring-while-uitextview-editing-is
        guard let textView = sender.view as? UITextView else{
            return
        }
        if textView.text == ""{
            textView.becomeFirstResponder()
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
        
        print("characterIndex:\(characterIndex)")
        if characterIndex < textView.textStorage.length{
            //识别字符下标characterIndex处的富文本信息
            let attachment = textView.attributedText.attribute(NSAttributedString.Key.attachment,
                                                               at: characterIndex,
                                                               effectiveRange: nil) as? NSTextAttachment
            //1.字符下标characterIndex处为图片附件，则展示它
            if let attachment = attachment{
                //当日记的最后一个字符是图片时，进入编辑模式时自动将光标另起一行
                if characterIndex == textView.textStorage.length - 1{
                    textView.insertText("\n")
                    textView.selectedRange = NSMakeRange(characterIndex + 2, 0)
                    textView.becomeFirstResponder()
                    return
                }
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
            //2.字符下标characterIndex处不是图片附件而是字符，则将光标移到触摸的字符下标
            }else{
                //bug：点击新的下标时，先调用唤醒了keyboardWillChangeFrameNotification，再调用了tapOnImage()
                //在下标还没有被赋予新值之前（点击textView瞬间），调用了observer，将视角滑向了旧下标。
                if !textView.isFirstResponder{
                    textView.becomeFirstResponder()
                }
                if characterIndex == textView.textStorage.length - 1{
                    textView.selectedRange = NSMakeRange(characterIndex + 1, 0)
                }else{
                    textView.selectedRange = NSMakeRange(characterIndex, 0)
                }
                textView.scrollRangeToVisible(textView.selectedRange)
            }
        }
    }
}

//MARK:-生命周期
extension todayVC{
    //读入选中的日记
    func loadTodayData(){
        todayDiary = DataContainerSingleton.sharedDataContainer.selectedDiary
        //如果没有选择新的日期，不要刷新避免读取一样的内容
        if lastDiary == todayDiary.date!{
            return
        }
        //load pictures
        photoImages.removeAll()
        for uuid in todayDiary.uuidofPictures {
            let path = getDocumentsDirectory().appendingPathComponent(uuid)
            photoImages.append(UIImage(contentsOfFile: path.path)!)
        }
        
        //load textView
        if todayDiary.content.count == 0{
            //palce holder
            textView.attributedText = NSAttributedString.textViewPlaceholder()
        }else{
            textView.textColor = UIColor.black
            if let aString = loadAttributedString(date_string: todayDiary.date!){
                //暂时用空白图片填充
//                let preparedText = processAttrString(aString: aString,fillWithEmptyImage: true)
                let preparedText = aString.processAttrString(textView: self.textView,fillWithEmptyImage: true)
                textView.attributedText = preparedText
            }
        }
        
        //load ohter info
        topbar.dataLable1.text = todayDiary.date
        topbar.dataLable2.text = Date().getWeekday(dateString: todayDiary.date!)
        if todayDiary.date == getTodayDate(){
            topbar.dataLable2.text! += "*"
        }
        topbar.dataLable1.sizeToFit()
        topbar.button1.islike = todayDiary.islike
        topbar.button2.buttonImageView.image = UIImage(named: todayDiary.mood.rawValue)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopbar()
        configureTodayView()
        loadTodayData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //获取欲展示的日记
        loadTodayData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if lastDiary == todayDiary.date!{
            return
        }else{
            if textView.textColor == UIColor.lightGray{
                //空日记，不读取，否则placeholder被读取的空文本覆盖
                lastDiary = todayDiary.date!
                return
            }
            print("将新日记的图片填入空白")
            if let aString = loadAttributedString(date_string: todayDiary.date!){
                let preparedText = aString.processAttrString(textView: self.textView,fillWithEmptyImage: false)
                textView.attributedText = preparedText
            }
        }
        
        lastDiary = todayDiary.date!
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("todayVC viewDidDisappear")
        if textView.textColor == UIColor.lightGray{
            return
        }
    }
    
}
