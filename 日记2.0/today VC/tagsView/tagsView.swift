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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add panGesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        restoreDate()
        configTagsView()
    }
    
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
//        print("view.frame.height:\(view.frame.height)")
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

extension tagsView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContainerSingleton.sharedDataContainer.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tagsCell.reusableId) as! tagsCell
        let row = indexPath.row
        cell.tagsLabel.text = DataContainerSingleton.sharedDataContainer.tags[row]
        //恢复以选取的tags
        if selectedTags.contains(DataContainerSingleton.sharedDataContainer.tags[row]) && cell.hasGetCorrectFrame{
            cell.hasSelected = true
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

extension tagsView{
    //MARK:-life cycle
    func restoreDate(){
        //恢复数据
        selectedMood = diary.mood
        selectedTags = diary.tags
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        print("tags view viewWillAppear")
//        let index = moodTypes.allCases.firstIndex(of: selectedMood!)! as Int
//        moodButtons[index].animateSelectedView(duration: 0.05)
//        tagsTableView.reloadData()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        //恢复数据的动画
//        print("tags view viewDidAppear")
        let index = moodTypes.allCases.firstIndex(of: selectedMood!)! as Int
        moodButtons[index].animateSelectedView()
        tagsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        print("tags view viewWillDisappear，tags:\(selectedTags)")
        if let selectedMood = selectedMood{
            diary.mood = selectedMood
        }
        diary.tags = selectedTags
    }
}
