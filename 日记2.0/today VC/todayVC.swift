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
        tagsViewController.transitioningDelegate = tagsViewController
        tagsViewController.modalPresentationStyle = .custom//模态
        return tagsViewController
    }()
    
    @IBOutlet weak var textView:UITextView!
    var keyBoardToolsBar:toolsBar!
    var keyBoardToolsBarFrame:CGRect!

    var lastDiary:String = ""
    
    let picker = UIImagePickerController()
    
    func configureTodayView(){
        //textView
        
        textView.delegate = self
        textView.font =  userDefaultManager.font
        
        //tools bar
        keyBoardToolsBar = toolsBar(frame: CGRect(x: 0, y: 900, width: UIScreen.main.bounds.width, height: 40))
        keyBoardToolsBarFrame = keyBoardToolsBar.frame
        keyBoardToolsBar.textView = textView
        keyBoardToolsBar.todayVC = self
        self.view.addSubview(keyBoardToolsBar)
        view.layoutIfNeeded()
        keyBoardToolsBar.alpha = 0
    }
    
    func configureTopbar(){
        //通知中心：响应button，响应键盘
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func todayButtonsTapped(button:topbarButton){
        switch button.tag {
        case 1:
            //设置“喜欢”
            button.islike.toggle()
            todayDiary.islike = button.islike
            //刷新monthVC
            let monthVC = UIApplication.getMonthVC()
            monthVC.calendar.reloadData()
            
            break
        case 2:
            //传递当前的diary
            tagsViewController.diary = todayDiary
            //call viewDidLoad()
            self.present(tagsViewController, animated: true, completion: nil)
            break
        case 3:
            let temptextView = UITextView(frame: textView.bounds)
            temptextView.attributedText = textView.attributedText
            //不能在原textView上进行截图，没办法把所有内容都截下来
            //除非在截图之前将textView.removeFromSuperview()
            let snapshot = temptextView.textViewImage()
            
            let vc = shareVC(diary: todayDiary, snapshot: snapshot)
            present(vc, animated: true, completion: nil)
            break
        default:
            return
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)//从screen坐标系转换为当前view坐标系
//        print("out keyboardViewEndFrame:\(keyboardViewEndFrame)")
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
            let containerVC = UIApplication.getPageViewContainer()
            let y = keyboardScreenEndFrame.origin.y - keyBoardToolsBarFrame.size.height - containerVC.topbarHeight - containerVC.view.safeAreaInsets.top
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)
            keyBoardToolsBar.alpha = 1
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyBoardToolsBar.frame.height, right: 0)
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
}


//MARK:-插入图片
extension todayVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func importPicture() {
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
        
        mutableStr.addAttribute(NSAttributedString.Key.font, value: userDefaultManager.font, range: NSMakeRange(0,mutableStr.length))
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
    
    func textViewDidChange(_ textView: UITextView) {
//        print("textViewDidChange")
        //处理数字序号的更新(当某一段从有内容变成一个空行时调用correctNum方法)
        let textFormatter = TextFormatter(textView: textView)
        if let curParaString = textFormatter.getCurParaString(){
            if curParaString == "\n"{
                textFormatter.correctNum()
            }
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
        if todayDiary.month == monthVC.selectedMonth{
//            print("月份:\(todayDiary.month),刷新行:\(todayDiary.row + 1)th")
            //仅当日记对应的月份和当前monthvc显示的月份一致时，才需要刷新collectionView
            monthVC.reloadCollectionViewData(forRow: todayDiary.row)
            monthVC.calendar.reloadData()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //1.当换行时，调用addNewLine()来处理递增数字列表的任务
        let textFormatter = TextFormatter(textView: textView)
        if text == "\n"{
            textFormatter.addNewLine()
            return false
        }
        
        //2.当删除一行，光标移到上一行时，更新其后所有行的序号
        textFormatter.correctNum(deleteRange: range)
        
        //3.其余情况
        textView.typingAttributes = leftTypingAttributes()
        //除了换行符，其他的字符无需处理，正常输出即可
        return true//若为false，键入的新字符不会递给storage
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let aString = textView.attributedText!
        let bounds = self.textView.bounds
        let range = characterRange
        print("range:\(range)")
        aString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: [], using: { [] (object, range, pointer) in
            let textViewAsAny: Any = textView
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: textViewAsAny as? NSTextContainer, characterIndex: range.location){
                textView.resignFirstResponder()
                //展示image
                let browser = JXPhotoBrowser()
                browser.numberOfItems = { 1 }
                browser.reloadCellAtIndex = { context in
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    browserCell?.imageView.image = img
                }
                browser.show()
                return
            }
            })
        
        //
        return true
    }
 
}

//MARK:-生命周期
extension todayVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopbar()
        configureTodayView()
        loadTodayData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //展示点击的日记
//        loadTodayData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func loadTodayData(){
        todayDiary = DataContainerSingleton.sharedDataContainer.selectedDiary
        //如果没有选择新的日期，不要刷新避免读取一样的内容
        if lastDiary == todayDiary.date!{
            return
        }
        lastDiary = todayDiary.date!
        
        //load textView
        if todayDiary.content.count == 0{
            //palce holder
            textView.attributedText = NSAttributedString.textViewPlaceholder()
        }else{
            textView.textColor = UIColor.black
            textView.text = todayDiary.content//第一次使用app，没有aString可读取，此时将text设置为introduc.txt
            textView.typingAttributes = leftTypingAttributes()//内容居左
            let textViewBounds = textView.bounds
            DispatchQueue.global(qos: .default).async {
                if let aString = loadAttributedString(date_string: self.todayDiary.date!){
                    //异步读取attributedString、异步处理图片bounds
                    let preparedText = aString.processAttrString(bounds: textViewBounds)
                    DispatchQueue.main.async {
                        self.textView.attributedText = preparedText
                    }
                }
            }
            
        }
        
        //load topbar info
        topbar.dataLable1.text = todayDiary.date
        topbar.dataLable2.text = Date().getWeekday(dateString: todayDiary.date!)
        if todayDiary.date == getTodayDate(){
            topbar.dataLable2.text! += "*"
        }
        topbar.dataLable1.sizeToFit()
        topbar.button1.islike = todayDiary.islike
        topbar.button2.buttonImageView.image = UIImage(named: todayDiary.mood.rawValue)
    }
    
    
   
    
}
