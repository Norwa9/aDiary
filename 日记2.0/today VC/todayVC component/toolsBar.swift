//
//  toolsBar.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/20.
//

import UIKit
import NVActivityIndicatorView

class toolsBar: UIView {
    weak var todayVC:todayVC!
    weak var textView:UITextView!
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var insertTimeButton:UIButton!
    @IBOutlet weak var insertImageButton:UIButton!
    @IBOutlet weak var numberListButton:UIButton!
    var saveButtonImageView:UIImageView!
    var insertTimeButtonImageView:UIImageView!
    var insertImageButtonImageView:UIImageView!
    var numberListButtonImageView:UIImageView!
    var indicator:NVActivityIndicatorView!
    
    func configureUI(){
        //save button
        saveButton.backgroundColor = .systemBackground
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        saveButtonImageView = UIImageView(image: UIImage(named: "done"))
        saveButtonImageView.contentMode = .scaleAspectFit
        saveButton.addSubview(saveButtonImageView)
        var width = saveButton.frame.width
        var height = saveButton.frame.height
        saveButtonImageView.centerInSuperview(size: CGSize(width: width*0.8, height: height*0.8))
        
        self.layoutIfNeeded()
        indicator = NVActivityIndicatorView(frame: saveButtonImageView.frame, type: .lineSpinFadeLoader, color: .lightGray, padding: .zero)
        indicator.alpha = 0
        saveButton.addSubview(indicator)
        
        //add time button
        insertTimeButton.backgroundColor = .systemBackground
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
        insertImageButton.backgroundColor = .systemBackground
        insertImageButton.addTarget(self, action: #selector(insertImageToTextView), for: .touchUpInside)
        insertImageButton.layer.cornerRadius = 10
        insertImageButton.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        insertImageButtonImageView = UIImageView(image: UIImage(named: "insertPicture"))
        insertImageButton.contentMode = .scaleAspectFit
        insertImageButton.addSubview(insertImageButtonImageView)
        width = insertImageButton.frame.width
        height = insertImageButton.frame.height
        insertImageButtonImageView.centerInSuperview(size: CGSize(width: width*0.8, height: height*0.8))
        
        //create number list
        numberListButton.backgroundColor = .systemBackground
        numberListButton.addTarget(self, action: #selector(setNumberList), for: .touchUpInside)
        numberListButton.layer.cornerRadius = 10
        numberListButton.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        numberListButtonImageView = UIImageView(image: UIImage(named: "numberList"))
        numberListButton.contentMode = .scaleAspectFit
        numberListButton.addSubview(numberListButtonImageView)
        width = numberListButton.frame.width
        height = numberListButton.frame.height
        numberListButtonImageView.centerInSuperview(size: CGSize(width: width*0.8, height: height*0.8))
    }
    
    @objc func saveButtonTapped(){
        self.statAnimateIndicator()
        todayVC.saveText()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.stopAnimatreIndicator()
            self.textView.resignFirstResponder()
        }
        
    }
    
    @objc func insertTimeToTextView(){
        textView.insertText(getExactCurrentTime())
    }
    
    @objc func insertImageToTextView(){
        todayVC.importPicture()
    }
    
    @objc func setNumberList(){
        let textFormatter = TextFormatter(textView: textView)
        textFormatter.orderedList()
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

}

//MARK:-indicator
extension toolsBar{
    func statAnimateIndicator(){
        UIView.animate(withDuration: 0.1) {
            self.saveButtonImageView.alpha = 0
            self.indicator.alpha = 1
        }
        self.indicator.startAnimating()
    }
    
    func stopAnimatreIndicator(){
        UIView.animate(withDuration: 0.1) {
            self.saveButtonImageView.alpha = 1
            self.indicator.alpha = 0
        }
        self.indicator.stopAnimating()
    }
}
