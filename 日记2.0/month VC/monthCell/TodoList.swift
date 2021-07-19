//
//  todoList.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoList: UIView {
    var collectionView:UICollectionView!
    
    var layout:UICollectionViewFlowLayout!
    
    var model:diaryInfo!
    
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
    
    func initData(_ model:diaryInfo){
        self.model = model
        self.todos = model.getTodos(for: .unchecked)
        print("getTodos:\(todos)")
        self.collectionView.reloadData()
    }
    
    func initUI(){
        
        self.layout = UICollectionViewFlowLayout()
        layout.scrollDirection  = .vertical
        layout.minimumLineSpacing = 5
        layout.estimatedItemSize = CGSize(width: self.frame.width, height: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TodoListCell.self, forCellWithReuseIdentifier: TodoListCell.cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        self.addSubview(collectionView)
        
        
        collectionView.setDebugBorder()
        

        
    }
    
    func setupConstraint(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
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
        print("dequeueReusableCell TodoListCell")
        cell.fillData(todo: todos[row])
        
        
        return cell
    }
    
    
}
