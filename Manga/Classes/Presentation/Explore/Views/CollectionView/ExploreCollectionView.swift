//
//  ExploreCollectionView.swift
//  Manga
//
//  Created by Андрей Чернышев on 19.07.2022.
//

import UIKit

protocol ExploreCollectionDelegate: AnyObject {
    func exploreCollectionDidTapped(category: Category)
    func exploreCollectionDidTapped(comics: ComicsCover)
}

final class ExploreCollectionView: UICollectionView {
    weak var mainDelegate: ExploreCollectionDelegate?
    
    private lazy var elements = [ExploreCollectionElement]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ExploreCollectionView {
    func setup(elements: [ExploreCollectionElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension ExploreCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch elements[indexPath.row] {
        case .verticalOffset:
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath)
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = UIColor.clear
            return cell
        case let .title(title):
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: ExploreCollectionTitleCell.self), for: indexPath) as! ExploreCollectionTitleCell
            cell.setup(title: title)
            return cell
        case let .categories(element):
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: ExploreCollectionCategoriesCell.self), for: indexPath) as! ExploreCollectionCategoriesCell
            cell.setup(elements: element) { [weak self] category in
                self?.mainDelegate?.exploreCollectionDidTapped(category: category)
            }
            return cell
        case let .comics(element):
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: ExploreCollectionComicsCell.self), for: indexPath) as! ExploreCollectionComicsCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ExploreCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .comics(let element):
            mainDelegate?.exploreCollectionDidTapped(comics: element.comics)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch elements[indexPath.row] {
        case .verticalOffset(let offset):
            return CGSize(width: 343.scale, height: offset)
        case .title:
            return CGSize(width: 343.scale, height: 24.scale)
        case .categories:
            return CGSize(width: 343.scale, height: 56.scale)
        case .comics:
            return CGSize(width: 163.scale, height: 339.scale)
        }
    }
}

// MARK: Private
private extension ExploreCollectionView {
    func initialize() {
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
        register(ExploreCollectionTitleCell.self, forCellWithReuseIdentifier: String(describing: ExploreCollectionTitleCell.self))
        register(ExploreCollectionCategoriesCell.self, forCellWithReuseIdentifier: String(describing: ExploreCollectionCategoriesCell.self))
        register(ExploreCollectionComicsCell.self, forCellWithReuseIdentifier: String(describing: ExploreCollectionComicsCell.self))
        
        dataSource = self
        delegate = self
    }
}
