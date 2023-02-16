//
//  ExploreCollectionComicsCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 19.07.2022.
//

import UIKit
import Kingfisher

final class ExploreCollectionComicsCell: UICollectionViewCell {
    lazy var comicsImageView = makeImageView()
    lazy var top5IconView = makeTop5IconView()
    lazy var nameLabel = makeLabel(numberOfLines: 2)
    lazy var categoriesLabel = makeLabel(numberOfLines: 1)
    lazy var statusContainer = makeStatusContainer()
    lazy var statusLabel = makeLabel(numberOfLines: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
extension ExploreCollectionComicsCell {
    func setup(element: ExploreComicsCover) {
        comicsImageView.kf.setImage(with: element.comics.imageUrl)
        
        top5IconView.isHidden = !element.comics.isTop5
        
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
        
        
        fill(status: element.comics.status)
    }
}

// MARK: Private
private extension ExploreCollectionComicsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
    
    func fill(status: ComicsStatus) {
        let text: String
        let containerColor: UIColor
        
        switch status {
        case .none:
            text = ""
            containerColor = UIColor.clear
        case .ongoing:
            text = "Explore.ComicsStatus.Ongoing".localized
            containerColor = Appearance.primary
        case .completed:
            text = "Explore.ComicsStatus.Completed".localized
            containerColor = Appearance.secondary1
        }
        
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
            .lineHeight(20.8.scale)
            .letterSpacing(-0.17.scale)
        
        statusContainer.backgroundColor = containerColor
        statusLabel.attributedText = text.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension ExploreCollectionComicsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            comicsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            comicsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            comicsImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            comicsImageView.heightAnchor.constraint(equalToConstant: 236.scale)
        ])
        
        NSLayoutConstraint.activate([
            top5IconView.widthAnchor.constraint(equalToConstant: 38.scale),
            top5IconView.heightAnchor.constraint(equalToConstant: 38.scale),
            top5IconView.trailingAnchor.constraint(equalTo: comicsImageView.trailingAnchor, constant: -10.scale),
            top5IconView.topAnchor.constraint(equalTo: comicsImageView.topAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: comicsImageView.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            categoriesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoriesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5.scale)
        ])
        
        NSLayoutConstraint.activate([
            statusContainer.centerXAnchor.constraint(equalTo: comicsImageView.centerXAnchor),
            statusContainer.bottomAnchor.constraint(equalTo: comicsImageView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 8.scale),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -8.scale),
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 4.scale),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ExploreCollectionComicsCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTop5IconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Explore.Top5")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel(numberOfLines: Int) -> UILabel {
        let view = UILabel()
        view.numberOfLines = numberOfLines
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeStatusContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 8.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
