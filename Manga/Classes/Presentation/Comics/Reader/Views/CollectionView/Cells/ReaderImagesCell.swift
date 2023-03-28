//
//  ReaderImagesCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 17.02.2023.
//

import UIKit

final class ReaderImagesCell: UICollectionViewCell {
    lazy var tableView = makeTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ReaderImagesCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension ReaderImagesCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReaderImagesCell {
    func makeTableView() -> ReaderTableImagesView {
        let view = ReaderTableImagesView()
        view.contentInset = UIEdgeInsets.zero
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
