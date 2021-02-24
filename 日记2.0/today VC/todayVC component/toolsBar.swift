//
//  toolsBar.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/20.
//

import UIKit

class toolsBar: UIView {
    weak var todayVC:todayVC!
    weak var textView:UITextView!
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var insertTimeButton:UIButton!
    @IBOutlet weak var insertImageButton:UIButton!
    var saveButtonImageView:UIImageView!
    var insertTimeButtonImageView:UIImageView!
    var insertImageButtonImageView:UIImageView!

    func configureUI(){
        //save button
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        saveButtonImageView = UIImageView(image: UIImage(named: "done"))
        saveButtonImageView.contentMode = .scaleAspectFit
        saveButton.addSubview(saveButtonImageView)
        var width = saveButton.frame.width
        var height = saveButton.frame.height
        saveButtonImageView.centerInSuperview(size: CGSize(width: width*0.8, height: height*0.8))
        
        //add time button
        insertTimeButton.addTarget(self, action: #selector(insertTimeToTextView), for: .touchUpInside)
        insertTimeButton.layer.cornerRadius = 10
        insertTimeButton.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        insertTimeButtonImageView = UIImageView(image: UIImage(named: "clock"))
        insertTimeButton.contentMode = .scaleAspectFit
        insertTimeButton.addSubview(insertTimeButtonImageView)
        width = insertTimeButton.frame.width
        height = insertTimeButton.frame.height
        insertTimeButtonImageView.centerInSuperview(size: CGSize(width: width*0.8, height: height*0.8))
        
        //insert picture button
        insertImageButton.addTarget(self, action: #selector(insertImageToTextView), for: .touchUpInside)
        insertImageButton.layer.cornerRadius = 10
        insertImageButton.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        insertImageButtonImageView = UIImageView(image: UIImage(named: "insertPicture"))
        insertImageButton.contentMode = .scaleAspectFit
        insertImageButton.addSubview(insertImageButtonImageView)
        width = insertImageButton.frame.width
        height = insertImageButton.frame.height
        insertImageButtonImageView.centerInSuperview(size: CGSize(width: width*0.8, height: height*0.8))
    }
    
    @objc func saveButtonTapped(){
        textView.resignFirstResponder()
    }
    
    @objc func insertTimeToTextView(){
        textView.insertText(getExactCurrentTime())
    }
    
    @objc func insertImageToTextView(){
        todayVC.importPicture()
//        todayVC.insertPictureToTextView(image: UIImage(named: "test2.jpeg")!)
    }
    
//MARK:-以下内容不需要修改
    var contentView:UIView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //布局相关设置：layoutSubviews()中可以获取autolayout后view的准确frame
        
    }
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadViewFromNib()
        addSubview(contentView)
        setUpConstraint()
        //初始化属性配置
        configureUI()
    }
    
     //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = loadViewFromNib()
        addSubview(contentView)
        setUpConstraint()
        //初始化属性配置
        configureUI()
    }
    
    //加载xib
    func loadViewFromNib() -> UIView{
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func setUpConstraint(){
        
    }

}
