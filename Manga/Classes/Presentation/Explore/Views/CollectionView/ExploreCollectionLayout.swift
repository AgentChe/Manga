//
//  ExploreCollectionLayout.swift
//  Manga
//
//  Created by Андрей Чернышев on 16.02.2023.
//

import UIKit

final class ExploreCollectionLayout: UICollectionViewFlowLayout {
    private var layoutInfo = [IndexPath: UICollectionViewLayoutAttributes]()
    
    private var contentHeight = CGFloat(0)
    
    override func prepare() {
        guard
            let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        else {
            return
        }
        
        layoutInfo = [:]

        let itemsCount = collectionView.numberOfItems(inSection: 0)
        
        var x = sectionInset.left
        var y = sectionInset.top
        
        let contentWidth = collectionView.bounds.width
        
        var lastHeight = CGFloat(0)
        
        for row in 0..<itemsCount {
            let indexPath = IndexPath(row: row, section: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            guard let itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) else {
                continue
            }
            
            let newLine = (x + itemSize.width) > contentWidth
            
            if newLine {
                x = sectionInset.left
                
                y += lastHeight + minimumLineSpacing
            }
            
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: itemSize)
            
            itemAttributes.frame = frame
            layoutInfo[indexPath] = itemAttributes
            
            x += itemSize.width + minimumInteritemSpacing
            
            lastHeight = itemSize.height
        }
        
        contentHeight = y + sectionInset.bottom + lastHeight - minimumLineSpacing
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutInfo[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        layoutInfo.forEach { key, value in
            if rect.intersects(value.frame) {
                attributes.append(value)
            }
        }
        
        return attributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        
        return CGSize(width: collectionView.bounds.width, height: contentHeight)
    }
}
