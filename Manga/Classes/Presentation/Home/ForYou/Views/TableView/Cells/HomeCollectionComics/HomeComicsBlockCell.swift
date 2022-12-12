//
//  HomeComicsBlockCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

final class HomeComicsBlockCell: UITableViewCell {
    lazy var titleLabel = makeLabel()
    lazy var arrowView = makeArrowView()
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
extension HomeComicsBlockCell {
    func setup(title: String, comics: [HomeComicsCover], canOpen: Bool, tapped: @escaping ((HomeComicsCover) -> Void)) {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.bold(size: 20.scale))
            .lineHeight(24.scale)
            .letterSpacing(-0.17.scale)
        titleLabel.attributedText = title.attributed(with: attrs)
        
        arrowView.isHidden = !canOpen
        
        collectionView.setup(elements: comics, tapped: tapped)
    }
}

// MARK: Private
private extension HomeComicsBlockCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeComicsBlockCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 24.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 24.scale),
            arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40.scale),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeComicsBlockCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Home.Arrow.Right")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCollectionView() -> HomeCollectionComicsView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16.scale
        layout.minimumInteritemSpacing = 16.scale
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16.scale, bottom: 0, right: 16.scale)
        
        let view = HomeCollectionComicsView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
