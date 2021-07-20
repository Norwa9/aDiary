//
//  todoList.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoList: UIView {
    var collectionView:UICollectionView!
    
    var layout:TodoListLayout!
    
    var viewModel:diaryInfo!
    
    ///未完成的todo
    var todos:[String] = []
    
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
        self.todos = viewModel.getTodos(for: .unchecked)
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
        
        
        return cell
    }
    
    
}
