//
//  ComicsProgressCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit

final class ComicsProgressCell: UITableViewCell {
    lazy var progressView = makeProgressView()
    
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
extension ComicsProgressCell {
    func setup(element: Float) {
        progressView.setProgress(element, animated: false)
    }
}

// MARK: Private
private extension ComicsProgressCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ComicsProgressCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 96.scale),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -96.scale),
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ComicsProgressCell {
    func makeProgressView() -> UIProgressView {
        let view = UIProgressView()
        view.layer.cornerRadius = 8.scale
        view.layer.masksToBounds = true
        view.trackTintColor = Appearance.grey
        view.progressTintColor = Appearance.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
