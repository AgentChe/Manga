//
//  HomeCollectionComicsView.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

final class HomeCollectionComicsView: UICollectionView {
    private lazy var elements = [HomeComicsCover]()
    private var tapped: ((HomeComicsCover) -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeCollectionComicsView {
    func setup(elements: [HomeComicsCover], tapped: @escaping ((HomeComicsCover) -> Void)) {
        self.elements = elements
        self.tapped = tapped
        
        reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension HomeCollectionComicsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionComicsCell.self), for: indexPath) as! HomeCollectionComicsCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension HomeCollectionComicsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 135.scale, height: 283.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        tapped?(element)
    }
}

// MARK: Private
private extension HomeCollectionComicsView {
    func initialize() {
        register(HomeCollectionComicsCell.self, forCellWithReuseIdentifier: String(describing: HomeCollectionComicsCell.self))
        
        dataSource = self
        delegate = self
    }
}
