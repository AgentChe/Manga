//
//  SettingsReadingModeButton.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import UIKit

final class SettingsReadingModeButton: UIButton {
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    lazy var checkedView = makeCheckedView()
    
    let readingMode: ReadingMode
    
    private lazy var unselectedAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
        .lineHeight(20.8.scale)
        .letterSpacing(-0.17.scale)
    private lazy var selectedAttrs = TextAttributes()
        .textColor(UIColor(integralRed: 80, green: 120, blue: 248))
        .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
        .lineHeight(20.8.scale)
        .letterSpacing(-0.17.scale)
    
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
private extension SettingsReadingModeButton {
    func update() {
        iconView.image = icon()
        
        let attrs = marked ? selectedAttrs : unselectedAttrs
        label.attributedText = title().attributed(with: attrs)
        
        checkedView.isHidden = !marked
    }
    
    func icon() -> UIImage? {
        let code = marked ? ".Selected" : ".Unselected"
        
        switch readingMode {
        case .vertical:
            return UIImage(named: "Settings.ReadingMode.Vertical" + code)
        case .rtl:
            return UIImage(named: "Settings.ReadingMode.RTL" + code)
        case .ltr:
            return UIImage(named: "Settings.ReadingMode.LTR" + code)
        }
    }
    
    func title() -> String {
        switch readingMode {
        case .vertical:
            return "Settings.ReadingMode.Vertical".localized
        case .rtl:
            return "Settings.ReadingMode.RTL".localized
        case .ltr:
            return "Settings.ReadingMode.LTR".localized
        }
    }
}

// MARK: Make constraints
private extension SettingsReadingModeButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32.scale),
            iconView.heightAnchor.constraint(equalToConstant: 32.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 58.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            checkedView.widthAnchor.constraint(equalToConstant: 16.scale),
            checkedView.heightAnchor.constraint(equalToConstant: 17.scale),
            checkedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            checkedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsReadingModeButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCheckedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Settings.Checked")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
