//
//  HomeCategoriesCollectionCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit
import Kingfisher

final class HomeCategoriesCollectionCell: UICollectionViewCell {
    lazy var nameLabel = makeLabel()
    
    private static let attrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
        .lineHeight(20.8.scale)
        .letterSpacing(-0.17.scale)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeCategoriesCollectionCell {
    static func size(for element: Category) -> CGSize {
        let size = element.name.attributed(with: HomeCategoriesCollectionCell.attrs).size()
        return CGSize(width: size.width + 32.scale, height: size.height + 24.scale)
    }
    
    func setup(element: Category) {
        nameLabel.attributedText = element.name.attributed(with: HomeCategoriesCollectionCell.attrs)
    }
}

// MARK: Private
private extension HomeCategoriesCollectionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension HomeCategoriesCollectionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeCategoriesCollectionCell {
    func makeLabel() -> PaddingLabel {
        let view = PaddingLabel()
        view.insets = UIEdgeInsets(top: 12.scale, left: 16.scale, bottom: 12.scale, right: 16.scale)
        view.backgroundColor = Appearance.black
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
