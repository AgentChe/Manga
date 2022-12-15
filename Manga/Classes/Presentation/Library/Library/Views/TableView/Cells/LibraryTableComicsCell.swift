//
//  LibraryTableComicsCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 22.07.2022.
//

import UIKit
import Kingfisher

final class LibraryTableComicsCell: UITableViewCell {
    lazy var comicsImageView = makeImageView()
    lazy var nameLabel = makeLabel()
    lazy var categoriesLabel = makeLabel()
    lazy var progressView = makeProgressView()
    lazy var menuButton = makeMenuButton()
    
    private lazy var nameLabelTopConstraint = NSLayoutConstraint()
    private lazy var categoriesLabelTopConstraint = NSLayoutConstraint()
    
    private var menuTapped: (() -> Void)?
    
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
extension LibraryTableComicsCell {
    func setup(element: LibraryTableComicsElement, menuTapped: @escaping () -> Void) {
        self.menuTapped = menuTapped
        
        comicsImageView.kf.setImage(with: element.comics.imageUrl)
        
        nameLabel.attributedText = element.comics.name
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white)
                            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
                            .lineHeight(20.8.scale)
                            .letterSpacing(-0.17.scale)
                            .lineBreakMode(.byTruncatingTail))
        
        let categories = element.categories.map { $0.name }.joined(separator: ", ")
        categoriesLabel.attributedText = categories
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white.withAlphaComponent(0.5))
                            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
                            .lineHeight(24.scale)
                            .letterSpacing(-0.17.scale)
                            .lineBreakMode(.byTruncatingTail))
        
        progressView.isHidden = element.progress == nil
        if let progress = element.progress {
            progressView.progress = progress
        }
        
        nameLabelTopConstraint.isActive = false
        categoriesLabelTopConstraint.isActive = false
        
        nameLabelTopConstraint.constant = element.progress == nil ? 14.scale : 4.scale
        categoriesLabelTopConstraint.constant = element.progress == nil ? 40.scale : 30.scale
        
        nameLabelTopConstraint.isActive = true
        categoriesLabelTopConstraint.isActive = true
        
        contentView.layoutIfNeeded()
    }
}

// MARK: Private
private extension LibraryTableComicsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func didTappedMenu() {
        menuTapped?()
    }
}

// MARK: Make constraints
private extension LibraryTableComicsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            comicsImageView.widthAnchor.constraint(equalToConstant: 54.scale),
            comicsImageView.heightAnchor.constraint(equalToConstant: 78.scale),
            comicsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            comicsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        nameLabelTopConstraint = nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.scale)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -47.scale),
            nameLabelTopConstraint
        ])
        
        categoriesLabelTopConstraint = categoriesLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30.scale)
        NSLayoutConstraint.activate([
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80.scale),
            categoriesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -47.scale),
            categoriesLabelTopConstraint
        ])
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80.scale),
            progressView.widthAnchor.constraint(equalToConstant: 140.scale),
            progressView.heightAnchor.constraint(equalToConstant: 6.scale),
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 68.scale)
        ])
        
        NSLayoutConstraint.activate([
            menuButton.widthAnchor.constraint(equalToConstant: 24.scale),
            menuButton.heightAnchor.constraint(equalToConstant: 24.scale),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension LibraryTableComicsCell {
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
    
    func makeProgressView() -> UIProgressView {
        let view = UIProgressView()
        view.layer.cornerRadius = 3.scale
        view.layer.masksToBounds = true
        view.trackTintColor = Appearance.black
        view.progressTintColor = Appearance.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeMenuButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Library.Menu"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTappedMenu), for: .touchUpInside)
        contentView.addSubview(view)
        return view
    }
}
