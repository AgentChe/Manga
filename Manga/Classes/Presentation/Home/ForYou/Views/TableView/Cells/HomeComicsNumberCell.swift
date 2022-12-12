//
//  HomeComicsNumberCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit
import Kingfisher

final class HomeComicsNumberCell: UITableViewCell {
    lazy var numberLabel = makeLabel()
    lazy var comicsImageView = makeImageView()
    lazy var nameLabel = makeLabel()
    lazy var categoriesLabel = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        comicsImageView.kf.cancelDownloadTask()
        comicsImageView.image = nil
    }
}

// MARK: Public
extension HomeComicsNumberCell {
    func setup(element: HomeComicsNumber) {
        let comics = element.comics
        
        comicsImageView.kf.setImage(with: comics.comics.imageUrl)
        
        numberLabel.attributedText = element.number
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white)
                            .font(Fonts.PlusJakartaSans.bold(size: 20.scale))
                            .lineHeight(24.scale)
                            .letterSpacing(-0.17.scale))
        
        nameLabel.attributedText = comics.comics.name
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white)
                            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
                            .lineHeight(20.8.scale)
                            .letterSpacing(-0.17.scale)
                            .lineBreakMode(.byTruncatingTail))
        
        let categories = comics.categories.map { $0.name }.joined(separator: ", ")
        categoriesLabel.attributedText = categories
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white.withAlphaComponent(0.5))
                            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
                            .lineHeight(24.scale)
                            .letterSpacing(-0.17.scale)
                            .lineBreakMode(.byTruncatingTail))
    }
}

// MARK: Private
private extension HomeComicsNumberCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeComicsNumberCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18.scale),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            comicsImageView.widthAnchor.constraint(equalToConstant: 54.scale),
            comicsImageView.heightAnchor.constraint(equalToConstant: 78.scale),
            comicsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 45.scale),
            comicsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 109.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -43.scale)
        ])
        
        NSLayoutConstraint.activate([
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 109.scale),
            categoriesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            categoriesLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeComicsNumberCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
