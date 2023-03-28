//
//  ReaderCollectionView.swift
//  Manga
//
//  Created by Андрей Чернышев on 17.02.2023.
//

import UIKit

protocol ReaderCollectionDelegate: AnyObject {
    func readerCollectionDidChanged(chapter: ComicsChapter)
}

final class ReaderCollectionView: UICollectionView {
    weak var mainDelegate: ReaderCollectionDelegate?
    
    private lazy var elements = [ComicsChapter]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ReaderCollectionView {
    func setup(elements: [ComicsChapter], scrollTo: ComicsChapter) {
        self.elements = elements
        
        reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.scroll(to: scrollTo)
        }
    }
    
    func scroll(to chapter: ComicsChapter) {
        guard let index = elements.firstIndex(where: { $0 == chapter }) else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        
        guard let frame = layoutAttributesForItem(at: indexPath)?.frame else {
            return
        }
        
        scrollRectToVisible(frame, animated: false)
    }
}

// MARK: UICollectionViewDataSource
extension ReaderCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch elements[indexPath.row].content {
        case .images(let urls):
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: ReaderImagesCell.self), for: indexPath) as! ReaderImagesCell
            cell.tableView.setup(elements: urls)
            return cell
        case .pdf(let url):
            return UICollectionViewCell()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ReaderCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard
            let cell = visibleCells.first,
            let index = indexPath(for: cell)?.row
        else {
            return
        }

        mainDelegate?.readerCollectionDidChanged(chapter: elements[index])
    }
}

// MARK: Private
private extension ReaderCollectionView {
    func initialize() {
        register(ReaderImagesCell.self, forCellWithReuseIdentifier: String(describing: ReaderImagesCell.self))
        
        dataSource = self
        delegate = self
    }
}
