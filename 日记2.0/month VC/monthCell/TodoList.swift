//
//  todoList.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

protocol todoListDelegate:AnyObject {
    func todoDidCheck(todo:String)
}

class TodoList: UIView {
    var collectionView:UICollectionView!
    
    var layout:TodoListLayout!
    
    var viewModel:diaryInfo!
    
    ///未完成的todo
    var todos:[String] = []
    var todoListType:todoType = .unchecked
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layout = TodoListLayout()
        layout.dataSource = self.todos
        
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TodoListCell.self, forCellWithReuseIdentifier: TodoListCell.cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .lightGray
        collectionView.layer.cornerRadius = 5
        self.addSubview(collectionView)
        
        
        //collectionView.setDebugBorder()
        

        
    }
    
    func setupConstraint(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func setViewModel(_ viewModel:diaryInfo){
        self.viewModel = viewModel
        updateUI()
        
    }
    
    func updateUI(){
        //更新布局的DataSource
        self.todos = viewModel.getTodos(for: self.todoListType)
        layout.dataSource = self.todos
        self.collectionView.reloadData()
    }
}

extension TodoList:UICollectionViewDelegate{
    
}

extension TodoList:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoListCell.cellId, for: indexPath) as! TodoListCell
        
        let row = indexPath.item
        cell.fillData(todo: todos[row])
        cell.delegate = self
        
        return cell
    }
    
    
}

//MARK:-todoListDelegate
extension TodoList:todoListDelegate{
    //按下了checkButton
    func todoDidCheck(todo: String) {
        let curTodos = viewModel.getTodos(for: self.todoListType)
        guard let indexInUnchecks = curTodos.firstIndex(of: todo) else {return}
        
        var todoAttributesTuplesCopy = viewModel.todoAttributesTuples
        
        var count = 0
        for (index,todoAttrTuple) in viewModel.todoAttributesTuples.enumerated(){
            if count == indexInUnchecks && todoAttrTuple.1 == self.todoListType.rawValue{
                todoAttributesTuplesCopy[index].1 = (todoAttrTuple.1 == 0 ? 1 : 0)
                LWRealmManager.shared.update {
                    //反转attribute的值
                    //这里整个数组重新赋值，目的是触发todoAttributesTuples的setter
                    viewModel.todoAttributesTuples = todoAttributesTuplesCopy
                }
                DiaryStore.shared.addOrUpdate(viewModel)
                updateTodoListViewAfterCheck(row: indexInUnchecks)
                return
            }
            if todoAttrTuple.1 == self.todoListType.rawValue{
                //计算所有todo中的unchecks个数
                count += 1
            }
        }
    }
    
    
    private func updateTodoListViewAfterCheck(row:Int){
        self.todos.remove(at: row)
        self.collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
        } completion: { _ in
            
        }
    }
}
