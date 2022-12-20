//
//  ReaderBottomView.swift
//  Manga
//
//  Created by Андрей Чернышев on 20.12.2022.
//

import UIKit

final class ReaderBottomView: UIView {
    lazy var shareButton = makeShareButton()
    lazy var markFinishButton = makeMarkFinishButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension ReaderBottomView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: 54.scale),
            shareButton.heightAnchor.constraint(equalToConstant: 54.scale),
            shareButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.scale),
            shareButton.topAnchor.constraint(equalTo: topAnchor, constant: 21.scale)
        ])
        
        NSLayoutConstraint.activate([
            markFinishButton.widthAnchor.constraint(equalToConstant: 166.scale),
            markFinishButton.heightAnchor.constraint(equalToConstant: 49.scale),
            markFinishButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 184.scale),
            markFinishButton.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReaderBottomView {
    func makeShareButton() -> ComicsNavButton {
        let view = ComicsNavButton()
        view.backgroundColor = Appearance.black
        view.iconView.image = UIImage(named: "Reader.Share")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeMarkFinishButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
            .letterSpacing(-0.17.scale)
        
        let view = UIButton()
        view.layer.cornerRadius = 16.scale
        view.backgroundColor = Appearance.primary
        view.setAttributedTitle("Reader.MarkAsFinished".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
