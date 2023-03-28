//
//  ReaderTableImagesCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 20.12.2022.
//

import UIKit
import Kingfisher

final class ReaderTableImagesCell: UITableViewCell {
    lazy var placeholderView = makePlaceholderView()
    lazy var pictureView = makeImageView()
    
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
        
        pictureView.kf.cancelDownloadTask()
        pictureView.image = nil
    }
}

// MARK: Public
extension ReaderTableImagesCell {
    func setup(imageUrl: URL, calculated: @escaping ((CGFloat) -> Void)) {
        pictureView.kf.setImage(with: imageUrl, completionHandler: { [weak self] result in
            guard let self = self, case let .success(image) = result else {
                return
            }
            
            self.placeholderView.isHidden = true
            
            let size = image.image.size
            let aspectRatio = size.height / size.width
            let height = self.frame.width * aspectRatio
            
            calculated(height)
        })
    }
}

// MARK: Private
private extension ReaderTableImagesCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReaderTableImagesCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            placeholderView.widthAnchor.constraint(equalToConstant: 85.scale),
            placeholderView.heightAnchor.constraint(equalToConstant: 80.scale),
            placeholderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pictureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pictureView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pictureView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pictureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReaderTableImagesCell {
    func makePlaceholderView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Reader.Placeholder")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
