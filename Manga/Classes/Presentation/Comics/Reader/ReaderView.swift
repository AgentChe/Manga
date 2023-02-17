//
//  ReaderView.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import UIKit

final class ReaderView: UIView {
    lazy var navView = makeNavView()
    lazy var collectionView = makeCollectionView()
    lazy var bottomView = makeBottomView()
    lazy var progressView = makeProgressView()
    
    private lazy var collectionViewBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ReaderView {
    func setup(title: String) {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
            .lineHeight(20.8.scale)
            .letterSpacing(-0.17.scale)
            .textAlignment(.center)
        navView.titleLabel.attributedText = title.attributed(with: attrs)
    }
    
    func bottomView(hidden: Bool) {
        bottomView.isHidden = hidden

        collectionViewBottomConstraint.isActive = false
        collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: hidden ? progressView.topAnchor : bottomView.topAnchor)
        collectionViewBottomConstraint.isActive = true

        layoutIfNeeded()
    }
}

// MARK: Private
private extension ReaderView {
    func initialize() {
        backgroundColor = Appearance.background
    }
}

// MARK: Make constraints
private extension ReaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            navView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navView.topAnchor.constraint(equalTo: topAnchor),
            navView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 99.scale : 69.scale)
        ])
        
        collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            collectionViewBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: progressView.topAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 123.scale : 93.scale)
        ])
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 6.scale),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReaderView {
    func makeNavView() -> ReaderNavView {
        let view = ReaderNavView()
        view.backgroundColor = Appearance.background
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCollectionView() -> ReaderCollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        let view = ReaderCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBottomView() -> ReaderBottomView {
        let view = ReaderBottomView()
        view.backgroundColor = Appearance.background
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProgressView() -> UIProgressView {
        let view = UIProgressView()
        view.trackTintColor = Appearance.black
        view.progressTintColor = Appearance.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
