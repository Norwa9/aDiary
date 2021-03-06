//
//  LWTextViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/21.
//

import UIKit
import JXPagingView
import FMPhotoPicker

class LWTextViewController: UIViewController {
    var baseVC : todayVC? {
        get{
            return UIApplication.getTodayVC()
        }
    }
    
    var model:diaryInfo!
    
    var textView:LWTextView!
    var keyBoardToolsBar:LWTextViewToolBar!
    
    var pickerConfig:FMPhotoPickerConfig = {
        var config = FMPhotoPickerConfig()
        config.availableFilters = nil
        config.mediaTypes = [.image]
        config.selectMode = .multiple
        config.maxImage = 9
        config.useCropFirst = true
        config.strings = KFMPhotoPickerCustomLanguageDict
        return config
    }()
//    lazy var picker:FMPhotoPickerViewController = {
//        return FMPhotoPickerViewController(config: pickerConfig)
//    }()
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    var isTextViewEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupConstraints()
        load()
        
        //键盘出现
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //键盘出现、隐藏、旋转···
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //设备方向
//        notificationCenter.addObserver(self, selector: #selector(onContainerSizeChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        globalConstantsManager.shared.currentDeviceOriention = UIDevice.current.orientation.rawValue
//        print("textVC viewWillAppear,当前设备方向：\(globalConstantsManager.shared.currentDeviceOriention )")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("textVC viewDidDisappear")
    }
    
    private func initUI(){
        //textView
        textView = LWTextView(frame: self.view.bounds, textContainer: nil)
        textView.delegate = self
        textView.textViewController = self
        textView.textContainerInset = UIEdgeInsets(top: 5, left: userDefaultManager.textInset, bottom: 0, right: userDefaultManager.textInset)
        self.view.addSubview(textView)
        
        
        //工具栏
        keyBoardToolsBar = LWTextViewToolBar(frame: CGRect(x: 0, y: 900, width: globalConstantsManager.shared.kScreenWidth, height: 40))
        keyBoardToolsBar.textView = textView
        keyBoardToolsBar.delegate = self
        view.layoutIfNeeded()
        textView.inputAccessoryView = keyBoardToolsBar
        
    }
    
    private func setupConstraints(){
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: -读取
    func load(){
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.loadTextViewContent(with: model)
    }
    
    //MARK: -保存
    func save(){
        //保存数据
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.save(with: model)
    }
}

//MARK: -键盘delegate
extension LWTextViewController{
    /// 显示
    @objc func adjustForKeyboardWillShow(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)//从screen坐标系转换为当前view坐标系
        let bottomInset:CGFloat
        if textView.contentSize.height < globalConstantsManager.shared.kScreenHeight{
            bottomInset = keyboardViewEndFrame.height
        }else{
            bottomInset = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }
        globalConstantsManager.shared.bottomInset = bottomInset
        
        if textView.isFirstResponder{
            print("textView.isFirstResponder")
        }else{
            // todo是焦点
            print("todoView.isFirstResponder")
            return // 返回，交给todoView去调整inset
        }
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    /// 隐藏
    @objc func adjustForKeyboardWillHide(notification: Notification) {
        if textView.isFirstResponder{
            textView.contentInset = .zero//键盘消失，文本框视图的缩进为0，与当前view的大小一致
        }
        // 如果todoView.isFirstResponder
        // 则不需要重新设置contentInset为零，因为如果换行新建todo时，会先resignFirstResponder再becomeFirstResponder，导致抖动
        textView.scrollRangeToVisible(textView.selectedRange)
        
    }
    
}

//MARK: -插入图片
extension LWTextViewController:LWPhotoPickerDelegate,FMPhotoPickerViewControllerDelegate,FMImageEditorViewControllerDelegate{
    
    func showPhotoPicker(){
        let picker = FMPhotoPickerViewController(config: pickerConfig)
        picker.delegate = self
        picker.undoManager?.disableUndoRegistration()
        self.present(picker, animated: true, completion: nil)
    }
    
    /// 多选图片
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        print(" didFinishPickingPhotoWith ")
    
        // 多选
        self.insertPhotos(images: photos)
        self.save()
        
        
        picker.dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func insertPhotos(images: [UIImage]){
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.insertScalableImageView(images: images)
    }
    
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        print(" didFinishEdittingPhotoWith ")
    }
    
    func toggleRecentPhotoPickerView(){
        if self.textView.inputView == nil{
            LWPhotoPrivacyHelper.shared.checkPhotoAccessabality {
                // 有图片访问权限，执行内部代码
                let inputView = LWRecentPhotosPickerView(
                    frame: CGRect(
                        origin: .zero,
                        size: CGSize(
                            width: globalConstantsManager.shared.kScreenWidth,
                            height: LWRecentPhotosPickerView.kRecentPhotosPickerViewHeight)
                    )
                )
                self.textView.inputView = inputView
                self.textView.reloadInputViews()
            }
        }else{
            self.textView.inputView = nil
            self.textView.reloadInputViews()
        }
        
        
    }
}

//MARK: 插入音频
extension LWTextViewController:LWSoundDelegate{
    func LWSoundDidFinishRecording(soundData: Data, soundFileLength: CGFloat) {
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.insertAudio(soundData: soundData,soundFileLength: soundFileLength)
        self.save()
    }
}

extension LWTextViewController : UITextViewDelegate{
    //MARK: -textViewDidBeginEditing
    func textViewDidBeginEditing(_ textView: UITextView) {
        isTextViewEditing = true
        keyBoardToolsBar.reloadTextViewToolBar(type: 0)
        //初始输入时，设置输入字体颜色为.label，否则默认为black无法适配深色模式
        if textView.textStorage.length == 0 {
            textView.typingAttributes[.foregroundColor] = UIColor.label
        }
    }
    
    //MARK: -textViewDidChangeSelection
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("textViewDidChangeSelection:\(textView.selectedRange)")
        keyBoardToolsBar.updateToolbarButtonsState(textView: textView as! LWTextView)
    }
    
    //MARK: -textViewDidChange
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
        //处理数字序号的更新(当某一段从有内容变成一个空行时调用correctNum方法)
        let textFormatter = TextFormatter(textView: textView as! LWTextView)
        if let curParaString = textFormatter.getCurParaString(){
            if curParaString == "\n"{
                textFormatter.correctNum()
            }
        }
    }
    
    //MARK: -textViewDidEndEditing
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        isTextViewEditing = false
        self.textView.inputView = nil
        save()
    }
    
    //MARK: -shouldChangeTextIn
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //当换行时，调用addNewLine()来处理递增数字列表的任务
        print("shouldChangeTextIn\(range)")
        let textFormatter = TextFormatter(textView: textView as! LWTextView)
        if text == "\n"{
            textFormatter.addNewLine()
            return false
        }
        
        //当删除一行，光标移到上一行时，更新其后所有行的序号
        textFormatter.correctNum(deleteRange: range)
        
        //其余情况:设置居左输入模式
        //textFormatter.setDefaultTypingAttributes()
        
        //除了换行符，其他的字符无需处理，正常输出即可
        return true//若为false，键入的新字符不会递给storage
    }

}

extension LWTextViewController : UIScrollViewDelegate{
    //MARK: -scrollViewDidScroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        // sprint("text view content offset : \(y)")
        
        //禁止下拉
        if y < 0{
            textView.contentOffset = .zero
            UIApplication.getTodayVC()?.draggingDownToDismiss = true
        }
    }
}

//MARK: -JXPagingViewListViewDelegate
extension LWTextViewController : JXPagingViewListViewDelegate{
    func listView() -> UIView {
        self.view
    }
    
    func listScrollView() -> UIScrollView {
        if let textView = self.textView{
            return textView
        }else{
            return LWTextView(frame: .zero)//如果左右滑动过快，self.textView尚未实例化，会返回nil奔溃
        }
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }
}

//MARK: -旋转屏幕时，需要重新调整页面UI
extension LWTextViewController{
    @objc private func onContainerSizeChanged(){
        guard UIDevice.current.userInterfaceIdiom == .pad else{
            return
        }
        
        //1.重新读取textView上的当前内容，目的是显示正确的图片bounds
        textView.resignFirstResponder() // 保存
        // let textFormatter = TextFormatter(textView: textView)
        // textFormatter.loadTextViewContent(with: model)
        self.load()
        
        //3.调整toolbar
        UIView.animate(withDuration: 0.5) {[self] in
            keyBoardToolsBar.frame.size.width = globalConstantsManager.shared.kScreenWidth
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("LWTextViewController viewWillTransition")
        
        //globalConstantsManager.shared.appSize = size// 这里不需要修改appSize了，在monthVC中已经修改
        self.onContainerSizeChanged()
    }
    
}

//MARK: -深色模式
extension LWTextViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //切换字体颜色为.label
        let labelColoredAttributedString = textView.attributedText!.restoreFontStyle()
        textView.attributedText = labelColoredAttributedString
        
    }
    
}
