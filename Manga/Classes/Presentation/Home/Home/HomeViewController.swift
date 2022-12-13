//
//  HomeViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit
import RxSwift

final class HomeViewController: UIViewController {
    lazy var mainView = HomeView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = HomeViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "For You Screen")
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        addSettingsButton()
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension HomeViewController {
    static func make() -> HomeViewController {
        let vc = HomeViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: HomeTableDelegate
extension HomeViewController: HomeTableDelegate {
    func homeTableDidTapped(comics: ComicsCover) {
        // TODO
//        let vc: UIViewController
//
//        let needPayment = !SessionManager().hasActiveSubscriptions()
//        if needPayment && book.paid {
//            vc = PaygateViewController.make()
//        } else {
//            vc = BookViewController.make(bookId: book.id)
//        }
//
//        present(vc, animated: true)
        print("tapped comics: \(comics.name)")
    }
    
    func homeTableDidTapped(category: Category) {
        let vc = ComicsByViewController.make(category: category)
        present(vc, animated: true)
    }
    
    func homeTableDidTappedComicsInProgress() {
        // TODO
        print("tapped comics in progress")
    }
    
    func homeTableDidTapped(ranking: Ranking) {
        let vc = ComicsByViewController.make(ranking: ranking)
        present(vc, animated: true)
    }
}

// MARK: Private
private extension HomeViewController {
    func addSettingsButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Home.Settings"), for: .normal)
        
        let item = UIBarButtonItem(customView: button)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
        
        button.rx.tap
            .bind(to: Binder(self) { base, void in
                // TODO
//                let vc = SettingsViewController.make()
//                base.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func activity(_ activity: Bool) {
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
