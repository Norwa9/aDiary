//
//  tagsView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import UIKit


class tagsView: UIViewController {
    //data
    var diary:diaryInfo!
    var selectedMood:moodTypes?
    var selectedTags = [String]()///局部变量，用来存储当前日记实时选择的tags
    
    @IBOutlet weak var doneButton:UIButton!
    @IBOutlet weak var dragBar:UIView!
    @IBOutlet weak var iconsContainer:UIView!
    var moodButtons = [moodButton]()
    @IBOutlet weak var tagsTableView:UITableView!
    
    var editMode:Bool = false{
        didSet{
//            tagsTableView.setEditing(editMode, animated: true)
        }
    }
    
    //panGesture
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    //MARK:-初始化UI
    func setupUI(){
        //configure drag bar
        dragBar.layer.cornerRadius = 4
        
        
        iconsContainer.backgroundColor = .systemBackground
        let frame = iconsContainer.frame
        let pedding = (frame.width - frame.height * 3) / 4
        for i in 0..<moodTypes.allCases.count{
            let button = moodButton(frame: CGRect(x: pedding * CGFloat(i+1) + frame.height * CGFloat(i), y: 0, width: frame.height, height: frame.height))
            button.moodType = moodTypes.allCases[i]
            button.addTarget(self, action: #selector(moodButtonTapped(sender:)), for: .touchUpInside)
            iconsContainer.addSubview(button)
            moodButtons.append(button)
        }
        
        let nib = UINib(nibName: tagsCell.reusableId, bundle: Bundle.main)
        tagsTableView.register(nib, forCellReuseIdentifier: tagsCell.reusableId)
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.separatorStyle = .none
        tagsTableView.showsVerticalScrollIndicator = false
        
    }
    
    //MARK:-button target
    @objc func moodButtonTapped(sender:moodButton){
        for button in moodButtons{
            if button != sender{
                if button.hasSelected{
                    button.animateSelectedView()
                }
            }
        }
        sender.animateSelectedView()
        selectedMood = sender.moodType
        //状态从未选改变到选中，则触发topbarButton的动画
        if sender.hasSelected{
            let topbarView = UIApplication.getTopbarView()
            topbarView.changeButtonImageView(topbarButtonIndex: 1, toImage: UIImage(named: sender.moodType.rawValue)!)
        }
        
    }
    
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
extension tagsView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContainerSingleton.sharedDataContainer.tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tagsCell.reusableId) as! tagsCell
        let row = indexPath.row
        cell.delegate = self
        cell.tagsLabel.text = DataContainerSingleton.sharedDataContainer.tags[row]
        //恢复tags的选取状态
        let selectedState = selectedTags.contains(DataContainerSingleton.sharedDataContainer.tags[row])
        cell.setView(hasSelected: selectedState,isEditMode: self.editMode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! tagsCell
        let row = indexPath.row

        //选取、反选动画
        cell.animateSelectedView()
        
        //统计到selectedTags
        let tag = DataContainerSingleton.sharedDataContainer.tags[row]
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
        customFooterView.backgroundColor = .white
        
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
        splitLine.backgroundColor = .lightGray
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
extension tagsView:tagsCellEditProtocol{
    
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
            if !DataContainerSingleton.sharedDataContainer.tags.contains(tag){
                DataContainerSingleton.sharedDataContainer.tags.append(tag)
                self.tagsTableView.reloadData()
            }
        }))
        ac.view.setupShadow()
        self.present(ac, animated: true, completion: nil)
    }
    
    //MARK:-2、编辑、删除标签
    func editButtonDidTapped(tag: String) {
        let tags = DataContainerSingleton.sharedDataContainer.tags
        print("当前的系统tags:\(tags)")
        guard let index = tags.firstIndex(of: tag) else{return}
        let indexPath = IndexPath(row: index, section: 0)
        
        let ac = UIAlertController(title: "编辑标签", message: "修改或者删除", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.text = tag
        }
        //删除
        let deleteAction = UIAlertAction(title: "删除", style: .destructive){_ in
            DataContainerSingleton.sharedDataContainer.tags.remove(at: index)
            self.tagsTableView.deleteRows(at: [indexPath], with: .fade)
            //更新当前日记的选中tags
            if let deleteIndex = self.selectedTags.firstIndex(of: tag){
                self.selectedTags.remove(at: deleteIndex)
            }
            //更新全部日记的选中tags
            DataContainerSingleton.sharedDataContainer.updateTags(oldTag: tag, newTag: nil)
        }
        //修改
        let editAction = UIAlertAction(title: "确定", style: .default){_ in
            guard let newTag = ac.textFields?[0].text else{return}
            DataContainerSingleton.sharedDataContainer.tags[index] = newTag
            //更新当前日记的选中tags
            if let editIndex = self.selectedTags.firstIndex(of: tag){
                self.selectedTags[editIndex] = newTag
            }
            self.tagsTableView.reloadRows(at: [indexPath], with: .fade)
            //更新全部日记的选中tags
            DataContainerSingleton.sharedDataContainer.updateTags(oldTag: tag, newTag: newTag)
        }
        //刷新
        ac.addAction(deleteAction)
        ac.addAction(editAction)
        ac.view.setupShadow()
        self.present(ac, animated: true, completion: nil)
        
    }
}

extension tagsView:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return tagsVC(presentedViewController: presented, presenting: presenting)
    }
}

//MARK:-life cycle
extension tagsView{

    func configureDate(){
        //绑定数据
        selectedMood = diary.mood
        selectedTags = diary.tags
        
        //恢复标签、心情选择状态
        for button in moodButtons{
            if button.hasSelected{
                button.animateSelectedView()
            }
        }
        if let mood = selectedMood{
            let index = moodTypes.allCases.firstIndex(of: mood)! as Int
            moodButtons[index].animateSelectedView()
        }
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
        print("tagsView viewWillAppear")
        configureDate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //保存tags和mood的选项
        if let selectedMood = selectedMood{
            diary.mood = selectedMood
        }
        print("tagsView关闭，保存已选中的tags:\(selectedTags)")
        diary.tags = selectedTags
        let monthVC = UIApplication.getMonthVC()
        monthVC.reloadCollectionViewData()
    }
}
