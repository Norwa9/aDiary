//
//  todayVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import FMPhotoPicker

class todayVC: UIViewController {
    var todayDiary:diaryInfo = {
        let date = getTodayDate()
        let predicate = NSPredicate(format: "date == %@", date)
        if let todayDiary = LWRealmManager.shared.query(predicate: predicate).first{
            return todayDiary
        }else{
            let newDiary = diaryInfo(dateString: date)
            LWRealmManager.shared.add(newDiary)
            return newDiary
        }
    }()
    
    weak var topbar:topbarView!
    
    lazy var tagsViewController:tagsView = {
        //配置tagsView
        let tagsViewController = tagsView()
        tagsViewController.transitioningDelegate = tagsViewController
        tagsViewController.modalPresentationStyle = .custom//模态
        tagsViewController.completionHandler = save
        return tagsViewController
    }()
    
    @IBOutlet weak var textView:UITextView!
    var keyBoardToolsBar:toolsBar!
    var keyBoardToolsBarFrame:CGRect!

    var lastDiary:String = ""
    
    var pickerConfig:FMPhotoPickerConfig = {
        var config = FMPhotoPickerConfig()
        config.availableFilters = nil
        config.mediaTypes = [.image]
        config.selectMode = .single
        config.useCropFirst = true
        config.strings = KFMPhotoPickerCustomLanguageDict
        return config
    }()
    var picker = UIImagePickerController()
    
    var diaryStore:DiaryStore!
    
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
    
    //MARK:-notification Center
    func configureTopbar(){
        //通知中心：响应button，响应键盘
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    //MARK:-topbar 按钮
    func todayButtonsTapped(button:topbarButton){
        switch button.tag {
        case 1:
            //设置“喜欢”
            button.islike.toggle()
            LWRealmManager.shared.update {
                todayDiary.islike = button.islike
            }
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
            let vc = shareVC(diary: todayDiary)
            vc.snapshot = textView.textViewImage()//传入textView的截图
            present(vc, animated: true, completion: nil)
            break
        default:
            return
        }
    }
    
    //MARK:-键盘delegate
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
extension todayVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,FMImageEditorViewControllerDelegate{
    func importPicture(){
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            let editor = FMImageEditorViewController(config: pickerConfig, sourceImage: image)
            editor.delegate = self
            picker.present(editor, animated: true, completion: nil)
        }
    }
    
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.insertPictureToTextView(image: photo)
        editor.dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:-UITextView Delegate
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
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let aString = textView.attributedText!
        aString.enumerateAttribute(.todo, in: NSRange(location: 0, length: aString.length), options: [], using: { [] (object, range, pointer) in
            print(range)
        })
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //开启左右滑动
        let customPageVC = UIApplication.getcustomPageViewController()
        customPageVC.pageScrollView.isScrollEnabled = true
        
        save()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //当换行时，调用addNewLine()来处理递增数字列表的任务
        print("shouldChangeTextIn\(range)")
        let textFormatter = TextFormatter(textView: textView)
        if text == "\n"{
            textFormatter.addNewLine()
            return false
        }
        
        //当删除一行，光标移到上一行时，更新其后所有行的序号
        textFormatter.correctNum(deleteRange: range)
        
        //其余情况:设置居左输入模式
        textFormatter.setLeftTypingAttributes()
        
        //除了换行符，其他的字符无需处理，正常输出即可
        return true//若为false，键入的新字符不会递给storage
    }
    
    //点按attachment( image or to-do)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let formatter = TextFormatter(textView: self.textView)
        let res = formatter.tappedAttchment(in: characterRange)
        return res
    }



}

//MARK:-生命周期
extension todayVC{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //配置日记存储器
        diaryStore =  DiaryStore.shared//同时会获取远端数据，上传本地未上传的数据
        
        self.configureTopbar()
        self.configureTodayView()
        self.loadTodayData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
     
}

//MARK:-helper
extension todayVC{
    //MARK:-读取日记内容
    func loadTodayData(selectedDiary:diaryInfo? = nil){
        
        if let selectedDiary = selectedDiary{
            todayDiary = selectedDiary
        }
        
        //读取textView
        let textFormatter = TextFormatter(textView: self.textView)
        if todayDiary.content.count == 0{
            //设置文字引导
            textFormatter.setPlaceholder()
        }else{
            textFormatter.loadTextViewContent(with: todayDiary)
        }
        
        //load topbar info
        topbar.dataLable1.text = todayDiary.date
        topbar.dataLable1.sizeToFit()
        
        topbar.dataLable2.text = Date().getWeekday(dateString: todayDiary.date)
        
        topbar.button1.islike = todayDiary.islike
        topbar.button2.buttonImageView.image = UIImage(named: todayDiary.mood)
    }
    
    //MARK:-保存更改
    func save(){
        //保存数据
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.save(with: todayDiary)
        
        //更新monthVC的UI
        let monthVC = UIApplication.getMonthVC()
        if todayDiary.month == monthVC.selectedMonth{
            //仅当日记对应的月份和当前monthvc显示的月份一致时，才需要刷新collectionView
            monthVC.reloadCollectionViewData(forRow: todayDiary.row)
            monthVC.calendar.reloadData()
        }
    }
    
    //MARK:-刷新UI
    func reloadTodayVC(){
        //读取attributedString
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.loadTextViewContent(with: todayDiary)
        
        //刷新图标
        topbar.button1.islike = todayDiary.islike
        topbar.button2.buttonImageView.image = UIImage(named: todayDiary.mood)
    }
    
}
