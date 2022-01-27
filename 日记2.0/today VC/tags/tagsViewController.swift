//
//  tagsView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import UIKit


class tagsViewController: UIViewController {
    //data
    var diary:diaryInfo!
    var selectedTags = [String]()///局部变量，用来存储当前日记实时选择的tags
    
    @IBOutlet weak var doneButton:UIButton!
    @IBOutlet weak var dragBar:UIView!
    @IBOutlet weak var tagsTableView:UITableView!
    
    var editMode:Bool = false{
        didSet{
//            tagsTableView.setEditing(editMode, animated: true)
        }
    }
    
    //panGesture
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    ///tagsViewController dismiss后的行为
    var completionHandler:(()->Void)?
    
    ///自定义初始化
    init(model:diaryInfo) {
        self.diary = model
        let nibName = (String(describing: type(of: self)) as NSString).components(separatedBy: ".").first!
        super.init(nibName: nibName, bundle: Bundle.main)
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom//模态
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:-初始化UI
    func setupUI(){
        //configure drag bar
        self.view.backgroundColor = .systemBackground
        dragBar.layer.cornerRadius = 4
        
        let nib = UINib(nibName: tagsCell.reusableId, bundle: Bundle.main)
        tagsTableView.register(nib, forCellReuseIdentifier: tagsCell.reusableId)
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.separatorStyle = .none
        tagsTableView.showsVerticalScrollIndicator = false
        tagsTableView.backgroundColor = .clear
        
    }
    
    //MARK:-button target
    
    //done button
    @IBAction func done(){
        dismiss(animated: true, completion: nil)
    }
    
//MARK:-拖动关闭tagsView
    //1
    override func viewDidLayoutSubviews() {
        //这个方法用来返回OverLayView的初始frame.origin，它返回的始终是一个定值
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    //2
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        print("translation:\(translation.x),\(translation.y)")
        guard translation.y >= 0 else { return }
        view.frame.origin.y = self.pointOrigin!.y + translation.y
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 || translation.y > 200{
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = self.pointOrigin?.y ?? 400
                }
            }
        }
    }
    
    

}

//MARK:-UITableViewDelegate
extension tagsViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.shared.tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tagsCell.reusableId) as! tagsCell
        let row = indexPath.row
        cell.delegate = self
        cell.tagsLabel.text = dataManager.shared.tags[row]
        //恢复tags的选取状态
        let selectedState = selectedTags.contains(dataManager.shared.tags[row])
        cell.setView(hasSelected: selectedState,isEditMode: self.editMode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! tagsCell
        let row = indexPath.row

        //选取、反选动画
        cell.animateSelectedView()
        
        //统计到selectedTags
        let tag = dataManager.shared.tags[row]
        if let firstIndex = selectedTags.firstIndex(of: tag){
            selectedTags.remove(at: firstIndex)
        }else{
            selectedTags.append(tag)
        }
    }
    //MARK:-移动cell
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if self.editMode{
//            return true
//        }else{
//            return false
//        }
//    }
    
    //MARK:-footerView
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let customFooterView = UIView()
        customFooterView.backgroundColor = .clear
        
        let addBtn = UIButton()
        addBtn.setImage(UIImage(named: "add"), for: .normal)
        customFooterView.addSubview(addBtn)
        addBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25, height: 25))
            make.right.equalTo(customFooterView)
            make.centerY.equalTo(customFooterView)
        }
        addBtn.addTarget(self, action: #selector(addNewTag), for: .touchUpInside)
        
        let editBtn = UIButton()
        editBtn.setImage(UIImage(named: "edit"), for: .normal)
        customFooterView.addSubview(editBtn)
        editBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25, height: 25))
            make.right.equalTo(addBtn.snp.left).offset(-5)
            make.centerY.equalTo(customFooterView)
        }
        editBtn.addTarget(self, action: (#selector(switchEditMode)), for: .touchUpInside)
        
        let splitLine = UIView()
        splitLine.backgroundColor = .separator
        customFooterView.addSubview(splitLine)
        splitLine.snp.makeConstraints { (make) in
            make.top.equalTo(customFooterView.snp.top)
            make.left.equalTo(editBtn.snp.left)
            make.right.equalTo(addBtn.snp.right)
            make.height.equalTo(1)
        }
        
        return customFooterView
    }
}

//MARK:-标签管理
extension tagsViewController:tagsCellEditProtocol{
    
    @objc func switchEditMode(){
        self.editMode.toggle()
        self.tagsTableView.reloadData()
    }
    //MARK:-1、添加标签
    @objc func addNewTag(){
        let ac = UIAlertController(title: "新标签", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            guard let tag = ac.textFields?[0].text else{
                return
            }
            if !dataManager.shared.tags.contains(tag){
                dataManager.shared.tags.append(tag)
                self.tagsTableView.reloadData()
            }
        }))
        ac.view.setupShadow()
        self.present(ac, animated: true, completion: nil)
    }
    
    //MARK:-2、编辑、删除标签
    func editButtonDidTapped(tag: String) {
        let tags = dataManager.shared.tags
        print("当前的系统tags:\(tags)")
        guard let index = tags.firstIndex(of: tag) else{return}
        let indexPath = IndexPath(row: index, section: 0)
        
        let ac = UIAlertController(title: "编辑标签", message: "修改或者删除", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.text = tag
        }
        //删除
        let deleteAction = UIAlertAction(title: "删除", style: .destructive){_ in
            dataManager.shared.tags.remove(at: index)
            self.tagsTableView.deleteRows(at: [indexPath], with: .fade)
            //更新当前日记的选中tags
            if let deleteIndex = self.selectedTags.firstIndex(of: tag){
                self.selectedTags.remove(at: deleteIndex)
            }
            //更新全部日记的选中tags
            dataManager.shared.updateTags(oldTag: tag, newTag: nil)
        }
        //修改
        let editAction = UIAlertAction(title: "确定", style: .default){_ in
            guard let newTag = ac.textFields?[0].text else{return}
            dataManager.shared.tags[index] = newTag
            //更新当前日记的选中tags
            if let editIndex = self.selectedTags.firstIndex(of: tag){
                self.selectedTags[editIndex] = newTag
            }
            self.tagsTableView.reloadRows(at: [indexPath], with: .fade)
            //更新全部日记的选中tags
            dataManager.shared.updateTags(oldTag: tag, newTag: newTag)
        }
        //刷新
        ac.addAction(deleteAction)
        ac.addAction(editAction)
        ac.view.setupShadow()
        self.present(ac, animated: true, completion: nil)
        
    }
}

extension tagsViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK:-life cycle
extension tagsViewController{

    func bindData(){
        //绑定数据
        selectedTags = diary.tags
        tagsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add panGesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bindData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LWRealmManager.shared.update {
            diary.tags = selectedTags
        }
        self.completionHandler?()
        //选取完标签后更新上传云端
        DiaryStore.shared.addOrUpdate(diary)
    }
}
