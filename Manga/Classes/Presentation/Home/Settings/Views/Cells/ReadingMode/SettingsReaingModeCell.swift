//
//  SettingsReaingModeCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import UIKit

final class SettingsReaingModeCell: UITableViewCell {
    var didSelect: ((ReadingMode) -> Void)?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var container = makeContainer()
    lazy var verticalButton = makeReadingModeButton(readingMode: .vertical)
    lazy var separator1 = makeSeparator()
    lazy var rtlButton = makeReadingModeButton(readingMode: .rtl)
    lazy var separator2 = makeSeparator()
    lazy var ltrButton = makeReadingModeButton(readingMode: .ltr)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SettingsReaingModeCell {
    func setup(element: ReadingMode) {
        verticalButton.marked = element == .vertical
        rtlButton.marked = element == .rtl
        ltrButton.marked = element == .ltr
    }
}

// MARK: Private
private extension SettingsReaingModeCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func didTap(sender: UIButton) {
        guard let button = sender as? SettingsReadingModeButton else {
            return
        }
        
        didSelect?(button.readingMode)
    }
}

// MARK: Make constraints
private extension SettingsReaingModeCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 208.scale)
        ])
        
        NSLayoutConstraint.activate([
            verticalButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            verticalButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            verticalButton.topAnchor.constraint(equalTo: container.topAnchor),
            verticalButton.heightAnchor.constraint(equalToConstant: 67.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator1.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            separator1.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator1.topAnchor.constraint(equalTo: verticalButton.bottomAnchor),
            separator1.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            rtlButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rtlButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            rtlButton.topAnchor.constraint(equalTo: separator1.bottomAnchor),
            rtlButton.heightAnchor.constraint(equalToConstant: 71.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator2.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            separator2.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator2.topAnchor.constraint(equalTo: rtlButton.bottomAnchor),
            separator2.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            ltrButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            ltrButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ltrButton.topAnchor.constraint(equalTo: separator2.bottomAnchor),
            ltrButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsReaingModeCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
            .lineHeight(20.8.scale)
            .letterSpacing(-0.17.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Settings.ReadingMode.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.black
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeReadingModeButton(readingMode: ReadingMode) -> SettingsReadingModeButton {
        let view = SettingsReadingModeButton(readingMode: readingMode)
        view.backgroundColor = UIColor.clear
        view.addTarget(self, action: #selector(didTap(sender:)), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
