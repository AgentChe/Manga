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
    
    private let continueToReadTapped: () -> Void
    
    private init(continueToReadTapped: @escaping () -> Void) {
        self.continueToReadTapped = continueToReadTapped
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        mainView.headerView.settingsButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let vc = SettingsViewController.make()
                base.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
}

// MARK: Make
extension HomeViewController {
    static func make(continueToReadTapped: @escaping () -> Void) -> HomeViewController {
        let vc = HomeViewController(continueToReadTapped: continueToReadTapped)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: HomeTableDelegate
extension HomeViewController: HomeTableDelegate {
    func homeTableDidTapped(comics: ComicsCover) {
        let vc: UIViewController

        let needPayment = !SessionManager().hasActiveSubscriptions()
        if needPayment && comics.paid {
            vc = PaygateViewController.make()
        } else {
            vc = ComicsViewController.make(comicsId: comics.id)
        }

        present(vc, animated: true)
    }
    
    func homeTableDidTapped(category: Category) {
        let vc = ComicsByViewController.make(category: category)
        present(vc, animated: true)
    }
    
    func homeTableDidTappedComicsInProgress() {
        continueToReadTapped()
    }
    
    func homeTableDidTapped(ranking: Ranking) {
        let vc = ComicsByViewController.make(ranking: ranking)
        present(vc, animated: true)
    }
}

// MARK: Private
private extension HomeViewController {
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
