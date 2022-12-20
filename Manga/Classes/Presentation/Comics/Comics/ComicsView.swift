//
//  ComicsView.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit

final class ComicsView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var downloadButton = makeDownloadButton()
    lazy var shareButton = makeShareButton()
    lazy var favoriteButton = makeFavoriteButton()
    lazy var tableView = makeTableView()
    lazy var readButton = makeReadButton()
    lazy var preloader = makePreloader()
    
    private lazy var tableViewTopConstraint = NSLayoutConstraint()
    
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
extension ComicsView {
    func updateButton(at inReading: Bool) {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))
            .letterSpacing(-0.17.scale)
        let title = inReading ? "Comics.Button.Read".localized : "Comics.Button.ReadFirst".localized
        readButton.setAttributedTitle(title.attributed(with: attrs), for: .normal)
    }
}

// MARK: Private
private extension ComicsView {
    func initialize() {
        backgroundColor = Appearance.background
    }
}

// MARK: Make constraints
private extension ComicsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 60.scale : 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            downloadButton.widthAnchor.constraint(equalToConstant: 41.scale),
            downloadButton.heightAnchor.constraint(equalToConstant: 41.scale),
            downloadButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 212.scale),
            downloadButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: 41.scale),
            shareButton.heightAnchor.constraint(equalToConstant: 41.scale),
            shareButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 265.scale),
            shareButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 41.scale),
            favoriteButton.heightAnchor.constraint(equalToConstant: 41.scale),
            favoriteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 318.scale),
            favoriteButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: readButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            readButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            readButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            readButton.heightAnchor.constraint(equalToConstant: 49.scale),
            readButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ComicsView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Comics.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDownloadButton() -> ComicsDownloadButton {
        let view = ComicsDownloadButton()
        view.backgroundColor = Appearance.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeShareButton() -> ComicsNavButton {
        let view = ComicsNavButton()
        view.backgroundColor = Appearance.black
        view.iconView.image = UIImage(named: "Comics.Share")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFavoriteButton() -> ComicsNavButton {
        let view = ComicsNavButton()
        view.backgroundColor = Appearance.black
        view.iconView.image = UIImage(named: "Comics.Mark.Uncheck")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> ComicsTableView {
        let view = ComicsTableView()
        view.contentInset = UIEdgeInsets(top: 30.scale.scale, left: 0, bottom: 30.scale, right: 0)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeReadButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
