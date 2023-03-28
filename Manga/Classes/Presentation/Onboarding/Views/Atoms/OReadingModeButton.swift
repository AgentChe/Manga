//
//  OReadingModeButton.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import UIKit

final class OReadingModeButton: UIButton {
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    let readingMode: ReadingMode
    
    init(readingMode: ReadingMode) {
        self.readingMode = readingMode
        
        super.init(frame: .zero)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension OReadingModeButton {
    func update() {
        layer.borderWidth = marked ? 2.scale : 0
        layer.borderColor = marked ? Appearance.primary.cgColor : UIColor.clear.cgColor
    }
    
    func icon() -> UIImage? {
        switch readingMode {
        case .vertical:
            return UIImage(named: "Onboarding.ReadingMode.Vertical")
        case .rtl:
            return UIImage(named: "Onboarding.ReadingMode.RTL")
        case .ltr:
            return UIImage(named: "Onboarding.ReadingMode.LTR")
        }
    }
    
    func title() -> String {
        switch readingMode {
        case .vertical:
            return "Onboarding.ReadingMode.Vertical".localized
        case .rtl:
            return "Onboarding.ReadingMode.RTL".localized
        case .ltr:
            return "Onboarding.ReadingMode.LTR".localized
        }
    }
}

// MARK: Make constraints
private extension OReadingModeButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48.scale),
            iconView.heightAnchor.constraint(equalToConstant: 48.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 74.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OReadingModeButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = icon()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
            .lineHeight(24.scale)
            .letterSpacing(-0.17.scale)
        
        let view = UILabel()
        view.attributedText = title().attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
