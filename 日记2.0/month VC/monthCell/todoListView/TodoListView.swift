//
//  todoList.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListView: UIView {
    var collectionView:UICollectionView!
    
    var layout:TodoListLayout = TodoListLayout()
    
    var viewModel:todoListViewModel!
    
    var diary:diaryInfo!
    
    ///未完成的todo
    var todoViewModels:[LWTodoViewModel] = []
    
    init() {
        super.init(frame: .zero)
        
        initUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        
        //collectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TodoListCell.self, forCellWithReuseIdentifier: TodoListCell.cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGray5//.black.withAlphaComponent(0.5)
        collectionView.layer.cornerRadius = 5
        self.addSubview(collectionView)
    }
    
    func setupConstraint(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func setDiary(_ diary:diaryInfo){
        self.diary = diary
        self.viewModel = todoListViewModel(diaryModel: diary, todoListView: self)
        self.todoViewModels = viewModel.getDataSource()
        layout.dataSource = self.todoViewModels
        // print("setDiary:\(diary.date),有\(todoViewModels.count)个todo")
        updateUI()
    }
    
    func updateUI(){
        //更新布局的DataSource
        layout.dataSource = self.todoViewModels
        collectionView.reloadData()
    }
    
    func updateViewHeightAndReloadData(newestDiary diary:diaryInfo,specifiedTodoUUID uuid:String? = nil){
        // 先更新DataSource，再作cell的动画
        // 但是cell的下标要在DataSource更新前计算
        var row:Int?
        if let uuid = uuid, let changedRow = self.todoViewModels.firstIndex(where: { viewModel in
            viewModel.uuid == uuid
        }) {
            row = changedRow
        }
        
        // 取得最新的todoListView的高度
        let todoListViewModel = todoListViewModel(diaryModel: diary, todoListView: self)
        let newestTodoViewModels = todoListViewModel.getDataSource()
        self.snp.updateConstraints { (make) in
            make.height.equalTo(self.calTodoListViewHeihgt(newestTodoViewModels: newestTodoViewModels))
        }
        
        //切换布局模式时，刷新todoListCell的宽度
        self.layout.dataSource = newestTodoViewModels
        self.todoViewModels = newestTodoViewModels
        reloadTodoView(specifiedRow: row)
    }
    
    private func reloadTodoView(specifiedRow row:Int?){
        if let row = row {
            //1.刷新collection view
            switch userDefaultManager.todoListViewStyle{
            case 0: // 默认
                break
            case 1: // 完成后移除
                self.collectionView.performBatchUpdates {
                    collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
                } completion: { _ in
                    
                }
            case 2: // 完成后置底
                break
            default:
                break
            }
            //2.
            //更新monthVC的collection view的布局，涉及到其他cell的位置改变
            //不能只更新单个cell
            UIApplication.getMonthVC()?.reloadCollectionViewData(forRow: -1,animated: true,animationDuration: 0.5)//更新全部cell
        }else{
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadData()//使用performBatchUpdates可以防止刷新时“闪一下”
            }, completion: nil)
        }
    }
    
    /// 根据最新的diary model刷新当前monthCell中的todoListView
    private func calTodoListViewHeihgt(newestTodoViewModels ViewModels:[LWTodoViewModel])->CGFloat{
        let count = ViewModels.count
        if count > 0{
            var h = 0.0
            for viewModel in ViewModels{
                h += viewModel.calSingleRowTodoViewHeihgt()
            }
            h +=  CGFloat(count) * (layoutParasManager.shared.todoListLineSpacing) + layoutParasManager.shared.todoListLineSpacing
            return h
        }else{
            return 0
        }
    }
}
//MARK:-UICollectionViewDelegate
extension TodoListView:UICollectionViewDelegate{
}

//MARK:-data source
extension TodoListView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoListCell.cellId, for: indexPath) as! TodoListCell
        let row = indexPath.item
        cell.setViewModel(todoViewModels[row])
        
        return cell
    }
    
    
}

//MARK:-todoListDelegate
extension TodoListView{

}
