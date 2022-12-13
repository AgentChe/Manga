//
//  ComicsByCollectionView.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit

protocol ComicsByCollectionDelegate: AnyObject {
    func comicsByCollectionTapped(comics: ComicsCover)
}

final class ComicsByCollectionView: UICollectionView {
    weak var mainDelegate: ComicsByCollectionDelegate?
    
    private lazy var elements = [ComicsByCollectionElement]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ComicsByCollectionView {
    func setup(elements: [ComicsByCollectionElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension ComicsByCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: ComicsByCollectionCell.self), for: indexPath) as! ComicsByCollectionCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ComicsByCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 163.scale, height: 323.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let element = elements[indexPath.row].comics
        mainDelegate?.comicsByCollectionTapped(comics: element)
    }
}

// MARK: Private
private extension ComicsByCollectionView {
    func initialize() {
        register(ComicsByCollectionCell.self, forCellWithReuseIdentifier: String(describing: ComicsByCollectionCell.self))
        
        dataSource = self
        delegate = self
    }
}
