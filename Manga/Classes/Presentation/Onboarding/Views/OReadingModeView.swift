//
//  OReadingModeView.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import UIKit

protocol OReadingModeViewDelegate: AnyObject {
    func readingModeViewDidSelected(readingMode: ReadingMode)
}

final class OReadingModeView: OSlideView {
    weak var readingModeDelegate: OReadingModeViewDelegate?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var verticalButton = makeButton(readingMode: .vertical)
    lazy var rtlButton = makeButton(readingMode: .rtl)
    lazy var ltrButton = makeButton(readingMode: .ltr)
    lazy var backButton = makeBackButton()
    lazy var nextButton = makeNextButton()
    
    private lazy var buttons = [
        verticalButton,
        rtlButton,
        ltrButton
    ]
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
        checkEnabled()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension OReadingModeView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 33, green: 33, blue: 33)
    }
    
    @objc
    func readingModeTapped(sender: UIButton) {
        guard let readingModeButton = sender as? OReadingModeButton else {
            return
        }
        
        buttons.forEach { $0.marked = false }
        
        readingModeButton.marked = true
        
        checkEnabled()
    }
    
    @objc
    func nextTapped() {
        guard let readingMode = buttons.first(where: { $0.marked })?.readingMode else {
            return
        }
        
        readingModeDelegate?.readingModeViewDidSelected(readingMode: readingMode)
        
        onNext()
    }
    
    func checkEnabled() {
        let marked = buttons.contains(where: { $0.marked })
        nextButton.isEnabled = marked
        nextButton.alpha = marked ? 1 : 0.4
    }
}

// MARK: Make constraints
private extension OReadingModeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 126.scale : 62.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            verticalButton.widthAnchor.constraint(equalToConstant: 305.scale),
            verticalButton.heightAnchor.constraint(equalToConstant: 72.scale),
            verticalButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            verticalButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            rtlButton.widthAnchor.constraint(equalToConstant: 305.scale),
            rtlButton.heightAnchor.constraint(equalToConstant: 72.scale),
            rtlButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            rtlButton.topAnchor.constraint(equalTo: verticalButton.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            ltrButton.widthAnchor.constraint(equalToConstant: 305.scale),
            ltrButton.heightAnchor.constraint(equalToConstant: 72.scale),
            ltrButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            ltrButton.topAnchor.constraint(equalTo: rtlButton.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 54.scale),
            backButton.heightAnchor.constraint(equalToConstant: 54.scale),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.widthAnchor.constraint(equalToConstant: 54.scale),
            nextButton.heightAnchor.constraint(equalToConstant: 54.scale),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OReadingModeView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.bold(size: 28.scale))
            .lineHeight(36.4.scale)
            .letterSpacing(-0.37.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.ReadingMode.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white.withAlphaComponent(0.6))
            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
            .lineHeight(24.scale)
            .letterSpacing(-0.17.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.ReadingMode.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeButton(readingMode: ReadingMode) -> OReadingModeButton {
        let view = OReadingModeButton(readingMode: readingMode)
        view.backgroundColor = Appearance.black
        view.layer.cornerRadius = 20.scale
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(readingModeTapped(sender:)), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeBackButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Onboarding.Back"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeNextButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Onboarding.Next"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        addSubview(view)
        return view
    }
}
