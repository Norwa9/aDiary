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
    var selectedTags = [String]()
    
    @IBOutlet weak var doneButton:UIButton!
    @IBOutlet weak var dragBar:UIView!
    @IBOutlet weak var iconsContainer:UIView!
    var moodButtons = [moodButton]()
    @IBOutlet weak var tagsTableView:UITableView!
    
    //panGesture
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?

    func configTagsView(){
        //configure drag bar
        dragBar.layer.cornerRadius = 4
        
        //configure mood buttons
        let frame = iconsContainer.frame
        let pedding = (frame.width - frame.height * 3) / 4
        for i in 0..<moodTypes.allCases.count{
            let button = moodButton(frame: CGRect(x: pedding * CGFloat(i+1) + frame.height * CGFloat(i), y: 0, width: frame.height, height: frame.height))
            button.moodType = moodTypes.allCases[i]
            button.addTarget(self, action: #selector(moodButtonTapped(sender:)), for: .touchUpInside)
            iconsContainer.addSubview(button)
            moodButtons.append(button)
        }
        
        //configure table view
        let nib = UINib(nibName: tagsCell.reusableId, bundle: Bundle.main)
        tagsTableView.register(nib, forCellReuseIdentifier: tagsCell.reusableId)
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.separatorStyle = .none
        
    }
    
    //button target
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
    
    //实现拖动关闭tagsView
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
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 || translation.y > 200{
                dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    @IBAction func addNewTag(){
        let ac = UIAlertController(title: "新标签", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            guard let tag = ac.textFields?[0].text else{
                return
            }
            DataContainerSingleton.sharedDataContainer.tags.append(tag)
            self.tagsTableView.reloadData()
        }))
        self.present(ac, animated: true, completion: nil)
    }

}

//MARK:-UITableViewDelegate
extension tagsView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContainerSingleton.sharedDataContainer.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tagsCell.reusableId) as! tagsCell
        let row = indexPath.row
        cell.tagsLabel.text = DataContainerSingleton.sharedDataContainer.tags[row]
        //令cell调用layoutSubviews()以获取真实的cell frame，为接下来恢复tags选取状态做准备。
        cell.layoutSubviews()
        //恢复tags的选取状态
        if selectedTags.contains(DataContainerSingleton.sharedDataContainer.tags[row]) {
            cell.hasSelected = true
        }else{
            cell.hasSelected = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! tagsCell
        let row = indexPath.row

        //选取、反选动画
        cell.hasSelected.toggle()
        //统计到selectedTags
        let tag = DataContainerSingleton.sharedDataContainer.tags[row]
        if let firstIndex = selectedTags.firstIndex(of: tag){
            selectedTags.remove(at: firstIndex)
        }else{
            selectedTags.append(tag)
        }
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return UITableViewCell.EditingStyle.delete
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
}

//MARK:-life cycle
extension tagsView{

    func configureDate(){
        //恢复数据
        selectedMood = diary.mood
        selectedTags = diary.tags
        
        //恢复选择状态
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
        
        configTagsView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("tagsView viewWillAppear")
        configureDate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //保存tags和mood的选项
        if let selectedMood = selectedMood{
            diary.mood = selectedMood
        }
        diary.tags = selectedTags
        let monthVC = UIApplication.getMonthVC()
        monthVC.collectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            monthVC.collectionView.reloadSections(indexSet)
                        }, completion: nil)
    }
}
