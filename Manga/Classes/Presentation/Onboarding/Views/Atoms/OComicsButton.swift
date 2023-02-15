//
//  OComicsButton.swift
//  Manga
//
//  Created by Андрей Чернышев on 24.08.2022.
//

import UIKit

class OComicsButton: UIButton {
    lazy var iconView = makeIconView()
    
    private let primaryImage: String
    private let highlitedImage: String
    
    init(primaryImage: String, highlitedImage: String) {
        self.primaryImage = primaryImage
        self.highlitedImage = highlitedImage
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Appearance.secondary1 : Appearance.black
            iconView.image = UIImage(named: isHighlighted ? highlitedImage : primaryImage)
        }
    }
}

// MARK: Make constraints
private extension OComicsButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 46.scale),
            iconView.heightAnchor.constraint(equalToConstant: 43.scale),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OComicsButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
