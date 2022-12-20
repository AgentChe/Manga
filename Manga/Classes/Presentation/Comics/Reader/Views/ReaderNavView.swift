//
//  ReaderNavView.swift
//  Manga
//
//  Created by Андрей Чернышев on 20.12.2022.
//

import UIKit

final class ReaderNavView: UIView {
    lazy var closeButton = makeCloseButon()
    lazy var titleLabel = makeTitleLabel()
    lazy var chaptersButton = makeChaptersButon()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension ReaderNavView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19.scale),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -17.scale)
        ])
        
        NSLayoutConstraint.activate([
            chaptersButton.widthAnchor.constraint(equalToConstant: 24.scale),
            chaptersButton.heightAnchor.constraint(equalToConstant: 24.scale),
            chaptersButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.scale),
            chaptersButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReaderNavView {
    func makeCloseButon() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Reader.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeChaptersButon() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Reader.Chapters"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
