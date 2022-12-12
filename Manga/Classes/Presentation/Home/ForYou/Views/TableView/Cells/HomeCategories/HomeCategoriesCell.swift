//
//  HomeCategoriesCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

final class HomeCategoriesCell: UITableViewCell {
    lazy var collectionView = makeCollectionView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeCategoriesCell {
    func setup(elements: [Category], tapped: @escaping ((Category) -> Void)) {
        collectionView.setup(elements: elements, tapped: tapped)
    }
}

// MARK: Private
private extension HomeCategoriesCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeCategoriesCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeCategoriesCell {
    func makeCollectionView() -> HomeCategoriesCollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.scale
        layout.minimumInteritemSpacing = 8.scale
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16.scale, bottom: 0, right: 16.scale)
        
        let view = HomeCategoriesCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
