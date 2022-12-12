//
//  HomeCategoriesCollectionView.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

final class HomeCategoriesCollectionView: UICollectionView {
    private lazy var elements = [Category]()
    private var tapped: ((Category) -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeCategoriesCollectionView {
    func setup(elements: [Category], tapped: @escaping ((Category) -> Void)) {
        self.elements = elements
        self.tapped = tapped
        
        reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension HomeCategoriesCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: HomeCategoriesCollectionCell.self), for: indexPath) as! HomeCategoriesCollectionCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension HomeCategoriesCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let element = elements[indexPath.row]
        let width = HomeCategoriesCollectionCell.width(for: element)
        return CGSize(width: width, height: 45.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        tapped?(element)
    }
}

// MARK: Private
private extension HomeCategoriesCollectionView {
    func initialize() {
        register(HomeCategoriesCollectionCell.self, forCellWithReuseIdentifier: String(describing: HomeCategoriesCollectionCell.self))
        
        dataSource = self
        delegate = self
    }
}
