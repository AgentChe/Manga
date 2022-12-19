//
//  ComicsInfoCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit

final class ComicsInfoCell: UITableViewCell {
    lazy var nameLabel = makeLabel(numberOfLines: 2)
    lazy var categoriesLabel = makeLabel(numberOfLines: 1)
    lazy var chaptersIconView = makeChaptersIconView()
    lazy var chaptersLabel = makeLabel(numberOfLines: 1)
    
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
extension ComicsInfoCell {
    func setup(element: ComicsTableInfoElement) {
        let nameAttrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.bold(size: 28.scale))
            .lineHeight(36.4.scale)
            .letterSpacing(-0.37.scale)
            .textAlignment(.center)
        nameLabel.attributedText = element.name.attributed(with: nameAttrs)
        
        let categoriesAttrs = TextAttributes()
            .textColor(Appearance.white.withAlphaComponent(0.6))
            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
            .lineHeight(24.scale)
            .letterSpacing(-0.17.scale)
            .lineBreakMode(.byTruncatingTail)
            .textAlignment(.center)
        categoriesLabel.attributedText = element.categories.attributed(with: categoriesAttrs)
        
        let chaptersAttrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
            .lineHeight(24.scale)
            .letterSpacing(-0.17.scale)
        let chapters = String(format: "Comics.ChaptersCount".localized, element.chaptersCount)
        chaptersLabel.attributedText = chapters.attributed(with: chaptersAttrs)
    }
}

// MARK: Private
private extension ComicsInfoCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ComicsInfoCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 38.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -38.scale),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -69.scale)
        ])
        
        NSLayoutConstraint.activate([
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 38.scale),
            categoriesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -38.scale),
            categoriesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5.scale)
        ])
        
        NSLayoutConstraint.activate([
            chaptersIconView.widthAnchor.constraint(equalToConstant: 24.scale),
            chaptersIconView.heightAnchor.constraint(equalToConstant: 24.scale),
            chaptersIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 129.scale),
            chaptersIconView.centerYAnchor.constraint(equalTo: chaptersLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            chaptersLabel.leadingAnchor.constraint(equalTo: chaptersIconView.trailingAnchor, constant: 5.scale),
            chaptersLabel.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ComicsInfoCell {
    func makeLabel(numberOfLines: Int) -> UILabel {
        let view = UILabel()
        view.numberOfLines = numberOfLines
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeChaptersIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Comics.Chapters")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
