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
    var keyBoardToolsBar:toolsBar!
    var keyBoardToolsBarFrame:CGRect!
    
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
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupConstraints()
        load()
        
        //键盘出现
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        //键盘出现、隐藏、旋转···
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //设备方向
        notificationCenter.addObserver(self, selector: #selector(onDeviceDirectionChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("textVC viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //load()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("textVC viewDidDisappear")
        //textView.attributedText = nil
    }
    
    private func initUI(){
        //textView
        textView = LWTextView(frame: self.view.bounds, textContainer: nil)
        textView.delegate = self
        self.view.addSubview(textView)
        
        
        //工具栏
        keyBoardToolsBar = toolsBar(frame: CGRect(x: 0, y: 900, width: UIScreen.main.bounds.width, height: 40))
        keyBoardToolsBarFrame = keyBoardToolsBar.frame
        keyBoardToolsBar.textView = textView
        keyBoardToolsBar.delegate = self
        view.layoutIfNeeded()
        keyBoardToolsBar.alpha = 0
        self.view.addSubview(keyBoardToolsBar)
        
    }
    
    private func setupConstraints(){
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK:-读取
    func load(){
        let textFormatter = TextFormatter(textView: self.textView)
        textFormatter.loadTextViewContent(with: model)
    }
    
    //MARK:-保存
    func save(){
        //保存数据
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.save(with: model)
    }
    
    
    
}

//MARK:-键盘delegate
extension LWTextViewController{
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        if textView.isFirstResponder {
            keyBoardToolsBar.keyboardType = .other
        }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)//从screen坐标系转换为当前view坐标系
        print("out keyboardViewEndFrame:\(keyboardViewEndFrame)")
        if notification.name == UIResponder.keyboardWillHideNotification {
            print("keyboardWillHideNotification")
            //1.键盘隐藏
            let x = keyBoardToolsBarFrame.origin.x
            let y = keyBoardToolsBarFrame.origin.y
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)//自带动画效果
            keyBoardToolsBar.alpha = 0
            textView.contentInset = .zero//键盘消失，文本框视图的缩进为0，与当前view的大小一致
        } else{
            print("keyboardWillChangeFrameNotification")
            //2.键盘出现
            let x = keyBoardToolsBarFrame.origin.x
            let y = keyboardScreenEndFrame.origin.y - keyBoardToolsBarFrame.size.height - 80 - 100
            //print("show point :\(CGPoint(x: x, y: y))")
            keyBoardToolsBar.frame.origin = CGPoint(x: x, y: y)
            keyBoardToolsBar.alpha = 1
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyBoardToolsBar.frame.height + keyBoardToolsBarFrame.height - 80 + 40, right: 0)
            //80=topview的高度，100=我也不知道为啥
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }
}

//MARK:-插入图片
extension LWTextViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,FMImageEditorViewControllerDelegate,LWPhotoPickerDelegate{
    func showPhotoPicker(){
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
extension LWTextViewController : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        if let todayVC = baseVC{
            if todayVC.isShowingTopView{
                todayVC.toggleTopView()
            }
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
        print("textViewDidEndEditing")
        baseVC?.toggleTopView()
        save()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //当换行时，调用addNewLine()来处理递增数字列表的任务
        //print("shouldChangeTextIn\(range)")
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
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let formatter = TextFormatter(textView: self.textView)
        let res = formatter.interactAttchment(with: characterRange,diary:model)
        if let type = res,type == .todo{
            self.save()
        }
        return true
    }

}

//MARK:-UIScrollViewDelegate
extension LWTextViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
        let y = scrollView.contentOffset.y
        print("text view content offset : \(y)")
        
        //自动隐藏/显示topView(当内容高度不及屏幕高度时，会出现bug)
        guard let todayVC = baseVC else {return}
        if textView.contentSize.height > globalConstantsManager.shared.kScreenHeight{
            if y > 50 && todayVC.isShowingTopView{
                todayVC.toggleTopView()
            }else if y < 10 && !todayVC.isShowingTopView{
                todayVC.toggleTopView()
            }
        }
        
    }
}

//MARK:-JXPagingViewListViewDelegate
extension LWTextViewController : JXPagingViewListViewDelegate{
    func listView() -> UIView {
        self.view
    }
    
    func listScrollView() -> UIScrollView {
        self.textView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }
}

//MARK:-旋转屏幕
extension LWTextViewController{
    @objc private func onDeviceDirectionChange(){
        guard UIDevice.current.userInterfaceIdiom == .pad else{
            return
        }
        //只响应横竖的变化
        guard UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isLandscape else{
            return
        }
        
        //1.重新读取textView上的当前内容，以显示正确的图片bounds
        textView.resizeImagesAttchement()
        
        //3.调整toolbar
        UIView.animate(withDuration: 0.5) {[self] in
            keyBoardToolsBar.frame.size.width = globalConstantsManager.shared.kScreenWidth
        }
        
    }
}

//MARK:-深色模式
extension LWTextViewController{
    ///切换模式后重新读取，以显示正确的todo复选框的素材
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        textView.reloadTodoImage()
    }
    
}
