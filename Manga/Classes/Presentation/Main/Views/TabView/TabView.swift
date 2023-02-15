//
//  TabView.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

final class TabView: UIView {
    enum Tab {
        case home, library, explore
    }
    
    lazy var homeItem = makeItem(code: "Main.Home")
    lazy var libraryItem = makeItem(code: "Main.Library")
    lazy var exploreItem = makeItem(code: "Main.Explore")
    
    var selectedTab = Tab.home {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TabView {
    func update() {
        [
            homeItem,
            libraryItem,
            exploreItem
        ]
        .forEach {
            $0.mode = .deselected
        }
        
        switch selectedTab {
        case .home:
            homeItem.mode = .selected
        case .library:
            libraryItem.mode = .selected
        case .explore:
            exploreItem.mode = .selected
        }
    }
}

// MARK: Make constraints
private extension TabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            homeItem.leadingAnchor.constraint(equalTo: leadingAnchor),
            homeItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            homeItem.topAnchor.constraint(equalTo: topAnchor),
            homeItem.widthAnchor.constraint(equalTo: libraryItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            libraryItem.leadingAnchor.constraint(equalTo: homeItem.trailingAnchor),
            libraryItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            libraryItem.topAnchor.constraint(equalTo: topAnchor),
            libraryItem.widthAnchor.constraint(equalTo: exploreItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            exploreItem.leadingAnchor.constraint(equalTo: libraryItem.trailingAnchor),
            exploreItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            exploreItem.topAnchor.constraint(equalTo: topAnchor),
            exploreItem.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension TabView {
    func makeItem(code: String) -> TabItemView {
        let view = TabItemView(code: code)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
