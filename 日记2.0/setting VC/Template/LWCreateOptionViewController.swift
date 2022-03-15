//
//  LWCreateOptionViewController.swift
//
//
//  Created by 罗威 on 2022/3/12.
//

import UIKit

enum LWCreateMode:Int{
    case newDay
    case newPage
}

class LWCreateOptionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var templates:[diaryInfo] = []
    private var layout:UICollectionViewFlowLayout!
    private var mode:LWCreateMode
    
    private var containerView:UIView!
    private var titleLabel:UILabel!
    private var creatNewBlankDiaryView:UIView!
    private var collectionView:UICollectionView!
    private var templateLabel:UILabel!
    private var manageTemplateButton:UIButton!
    private var noTemplatePromptLabel:UILabel!
    public var selectedDateCN:String?
    
    private let cellWidth = globalConstantsManager.shared.kScreenWidth - 100
    
    var createPageAction:((_ template:diaryInfo?) -> ()) = {template in }
    
    init(mode:LWCreateMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        initUI()
        setCons()
    }
    
    private func loadData(){
        templates = LWTemplateHelper.shared.getTemplateFor(templateRawName: nil)
    }
    
    public func reloadData(){
        templates = LWTemplateHelper.shared.getTemplateFor(templateRawName: nil)
        noTemplatePromptLabel.alpha = templates.isEmpty ? 1 : 0
        collectionView.reloadData()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.layer.cornerRadius = 10
        
        containerView = UIView()
        containerView.backgroundColor =  .systemBackground
        containerView.layer.cornerRadius = 10
        
        titleLabel = UILabel()
        if mode == .newDay{
            titleLabel.text = "创建日记"
        }else{
            titleLabel.text = "创建新页面"
        }
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        templateLabel = UILabel()
        templateLabel.text = "使用模板"
        templateLabel.textColor = .secondaryLabel
        templateLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        creatNewBlankDiaryView = setupCreateBlankView()
        
        
        manageTemplateButton = UIButton()
        let title = NSAttributedString(string: "管理模板").addingAttributes([
            .foregroundColor : UIColor.secondaryLabel,
            .font : UIFont.systemFont(ofSize: 14),
            .underlineColor : UIColor.secondaryLabel,
            .underlineStyle : 1
        ])
        manageTemplateButton.setAttributedTitle(title, for: .normal)
        manageTemplateButton.addTarget(self, action: #selector(showTempalteVC), for: .touchUpInside)
        
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth, height: 40)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LWTemplateCell.self, forCellWithReuseIdentifier: LWTemplateCell.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        noTemplatePromptLabel = UILabel()
        noTemplatePromptLabel.text = "暂无模板"
        noTemplatePromptLabel.font = UIFont.systemFont(ofSize: 14)
        noTemplatePromptLabel.textColor = .secondaryLabel
        noTemplatePromptLabel.alpha = templates.isEmpty ? 1 : 0
        
        self.view.addSubview(containerView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(creatNewBlankDiaryView)
        self.view.addSubview(templateLabel)
        self.view.addSubview(collectionView)
        self.view.addSubview(manageTemplateButton)
        self.view.addSubview(noTemplatePromptLabel)
        
    }
    
    private func setCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(18)
        }
        
        creatNewBlankDiaryView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(cellWidth)
            make.height.equalTo(40)
        }
        
        templateLabel.snp.makeConstraints { make in
            make.top.equalTo(creatNewBlankDiaryView.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel)
        }
        
        manageTemplateButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(templateLabel)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(templateLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        noTemplatePromptLabel.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
        }
    }
    
    private func setupCreateBlankView()->UIView{
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .secondarySystemBackground
        
        let label = UILabel()
        label.text = "创建空日记"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(createBlankDiary))
        view.addGestureRecognizer(tapGes)
        view.addSubview(label)
        
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }
    
    // MARK: 创建空日记/页面
    @objc func createBlankDiary(){
        if mode == .newDay{ // 新一天
            if let monthVC = UIApplication.getMonthVC(){
                let newDiary = diaryInfo(dateString: selectedDateCN ?? GetTodayDate())
                LWRealmManager.shared.add(newDiary)
                
                monthVC.configureDataSource(year: monthVC.selectedYear, month: monthVC.selectedMonth)
                self.dismiss(animated: true){
                    monthVC.presentEditorVC(withViewModel: newDiary)
                }
            }
        }else{ // 新页面
            createPageAction(nil) // template = nil 表示创建空日记
        }
        
    }
    
    @objc func showTempalteVC(){
        let vc = LWTemplateViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    
    // MARK: 创建模板日记/模板页面
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.row]
        
        if mode == .newDay{
            if let newDiary = LWTemplateHelper.shared.createDiaryUsingTemplate(dateCN: selectedDateCN ?? GetTodayDate(), pageIndex: 0, template: template),let monthVC = UIApplication.getMonthVC(){
                monthVC.configureDataSource(year: monthVC.selectedYear, month: monthVC.selectedMonth)
                self.dismiss(animated: true) {
                    monthVC.presentEditorVC(withViewModel: newDiary)
                }
            }
        }else{
            createPageAction(template)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LWTemplateCell.reuseID, for: indexPath) as! LWTemplateCell
        let row = indexPath.item
        cell.setViewModel(model:templates[row])
        return cell
    }

    

}


// MARK: UIViewControllerTransitioningDelegate
extension LWCreateOptionViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting,viewHeight: 300)
    }
}
