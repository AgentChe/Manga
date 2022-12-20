//
//  ComicsDownloadButton.swift
//  Manga
//
//  Created by Андрей Чернышев on 20.12.2022.
//

import UIKit

final class ComicsDownloadButton: TapAreaButton {
    enum State {
        case download
        case downloaded
        case downloading
    }
    
    lazy var iconView = makeImageView()
    lazy var preloader = makePreloader()
    
    var downloadState = State.download {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
    }
}

// MARK: Private
private extension ComicsDownloadButton {
    func update() {
        switch downloadState {
        case .download:
            iconView.isHidden = false
            iconView.image = UIImage(named: "Comics.Download")
            preloader.stopAnimating()
        case .downloaded:
            iconView.isHidden = false
            iconView.image = UIImage(named: "Comics.Download.Completed")
            preloader.stopAnimating()
        case .downloading:
            iconView.isHidden = true
            preloader.startAnimating()
        }
    }
}

// MARK: Make constraints
private extension ComicsDownloadButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 22.scale),
            iconView.heightAnchor.constraint(equalToConstant: 22.scale),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ComicsDownloadButton {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 22.scale, height: 22.scale), color: .main)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
