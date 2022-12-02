//
//  MainViewCoordinator.swift
//  BookSummaries
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

final class MainViewCoordinator {
    weak var parentVC: MainViewController?
    
    lazy var homeVC = NavigationController(rootViewController: UIViewController())
    lazy var libraryVC = NavigationController(rootViewController: UIViewController())
    lazy var exploreVC = NavigationController(rootViewController:UIViewController())
    
    private var previousVC: UIViewController?
    
    init(parentVC: MainViewController) {
        self.parentVC = parentVC
    }
    
    func change(tab: TabView.Tab) {
        parentVC?.mainView.tabView.selectedTab = tab
        
        switch tab {
        case .home:
            changeVC(on: homeVC)
        case .library:
            changeVC(on: libraryVC)
        case .explore:
            changeVC(on: exploreVC)
        }
    }
}

// MARK: Private
private extension MainViewCoordinator {
    func changeVC(on vc: UIViewController) {
        if let previousVC = self.previousVC {
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
        }
    
        self.previousVC = vc
        
        guard let parentVC = self.parentVC else {
            return
        }
    
        parentVC.addChild(vc)
        vc.view.frame = parentVC.mainView.container.bounds
        parentVC.mainView.container.addSubview(vc.view)
        vc.willMove(toParent: parentVC)
    }
}
