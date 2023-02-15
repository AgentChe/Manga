//
//  HomeFreeComicsCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit
import Kingfisher

final class HomeFreeComicsCell: UITableViewCell {
    lazy var placeholder1View = makePlaceholder1View()
    lazy var placeholder2View = makePlaceholder2View()
    lazy var comicsImageView = makeImageView()
    lazy var freeLabel = makeFreeLabel()
    lazy var nameLabel = makeLabel()
    lazy var categoriesLabel = makeLabel()
    lazy var statusContainer = makeStatusContainer()
    lazy var statusLabel = makeLabel()
    
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
extension HomeFreeComicsCell {
    func setup(element: HomeComicsCover) {
        comicsImageView.kf.setImage(with: element.comics.imageUrl)
        
        nameLabel.attributedText = element.comics.name
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white)
                            .font(Fonts.PlusJakartaSans.bold(size: 16.scale))
                            .lineHeight(19.2.scale)
                            .letterSpacing(-0.17.scale)
                            .textAlignment(.center)
                            .lineBreakMode(.byTruncatingTail))
        
        let categories = element.categories.map { $0.name }.joined(separator: ", ")
        categoriesLabel.attributedText = categories
            .attributed(with: TextAttributes()
                            .textColor(Appearance.white.withAlphaComponent(0.5))
                            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
                            .lineHeight(24.scale)
                            .letterSpacing(-0.17.scale)
                            .textAlignment(.center)
                            .lineBreakMode(.byTruncatingTail))
        
        fill(status: element.comics.status)
    }
}

// MARK: Private
private extension HomeFreeComicsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func fill(status: ComicsStatus) {
        let text: String
        let containerColor: UIColor
        
        switch status {
        case .none:
            text = ""
            containerColor = UIColor.clear
        case .ongoing:
            text = "Home.ComicsStatus.Ongoing".localized
            containerColor = Appearance.primary
        case .completed:
            text = "Home.ComicsStatus.Completed".localized
            containerColor = Appearance.secondary1
        }
        
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 12.scale))
            .lineHeight(14.4.scale)
        
        statusContainer.backgroundColor = containerColor
        statusLabel.attributedText = text.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension HomeFreeComicsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            placeholder1View.widthAnchor.constraint(equalToConstant: 294.scale),
            placeholder1View.heightAnchor.constraint(equalToConstant: 309.scale),
            placeholder1View.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholder1View.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholder2View.widthAnchor.constraint(equalToConstant: 295.scale),
            placeholder2View.heightAnchor.constraint(equalToConstant: 309.scale),
            placeholder2View.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholder2View.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            comicsImageView.widthAnchor.constraint(equalToConstant: 109.scale),
            comicsImageView.heightAnchor.constraint(equalToConstant: 158.scale),
            comicsImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            comicsImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 23.scale)
        ])
        
        NSLayoutConstraint.activate([
            freeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            freeLabel.topAnchor.constraint(equalTo: comicsImageView.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 44.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44.scale),
            nameLabel.topAnchor.constraint(equalTo: freeLabel.bottomAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 73.scale),
            categoriesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -73.scale),
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
private extension HomeFreeComicsCell {
    func makePlaceholder1View() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 48, green: 48, blue: 48, alpha: 0.5)
        view.layer.cornerRadius = 30.scale
        view.transform = CGAffineTransform(rotationAngle: (-6.31 * CGFloat.pi / 180))
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePlaceholder2View() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 51, green: 51, blue: 51)
        view.layer.cornerRadius = 30.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeFreeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.primary)
            .font(Fonts.PlusJakartaSans.extraBold(size: 16.scale))
            .lineHeight(19.2.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Home.FreeButton.Free".localized.attributed(with: attrs)
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
    
    func makeStatusContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 8.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
