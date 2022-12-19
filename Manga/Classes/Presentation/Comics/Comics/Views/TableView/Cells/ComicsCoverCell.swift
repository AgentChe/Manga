//
//  ComicsCoverCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit
import Kingfisher

final class ComicsCoverCell: UITableViewCell {
    lazy var comicsImageView = makeImageView()
    lazy var top5IconView = makeTop5IconView()
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
extension ComicsCoverCell {
    func setup(element: ComicsTableCoverElement) {
        comicsImageView.kf.setImage(with: element.imageUrl)
        
        top5IconView.isHidden = !element.top5
        
        fill(status: element.status)
    }
}

// MARK: Private
private extension ComicsCoverCell {
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
            text = "Comics.ComicsStatus.Ongoing".localized
            containerColor = Appearance.primary
        case .completed:
            text = "Comics.ComicsStatus.Completed".localized
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
private extension ComicsCoverCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            comicsImageView.widthAnchor.constraint(equalToConstant: 184.scale),
            comicsImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            comicsImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            comicsImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            top5IconView.widthAnchor.constraint(equalToConstant: 38.scale),
            top5IconView.heightAnchor.constraint(equalToConstant: 38.scale),
            top5IconView.trailingAnchor.constraint(equalTo: comicsImageView.trailingAnchor, constant: -10.scale),
            top5IconView.topAnchor.constraint(equalTo: comicsImageView.topAnchor, constant: 10.scale)
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
private extension ComicsCoverCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTop5IconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Home.Top5")
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
