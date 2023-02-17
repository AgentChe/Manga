//
//  ExploreViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 19.07.2022.
//

import UIKit
import RxSwift

final class ExploreViewController: UIViewController {
    lazy var mainView = ExploreView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = ExploreViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Explore Screen")
        
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
        
        mainView.searchView.changedState
            .map { $0 == .focus }
            .emit(to: viewModel.userSearching)
            .disposed(by: disposeBag)
        
        mainView.searchView.changedText
            .do(onNext: { text in
                AmplitudeManager.shared
                    .logEvent(name: "Explore Tap", parameters: ["what": "search"])
            })
            .emit(to: viewModel.search)
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(self) { base, result in
                base.mainView.collectionView.setup(elements: result.elements)
                
                let empty = result.checkOnEmpty ? result.elements.isEmpty : false
                base.content(empty: empty)
            })
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx.didScroll
            .bind(to: mainView.rx.hideKeyboardObserver)
            .disposed(by: disposeBag)
        
        mainView.rx.keyboardHeight
            .bind(to: Binder(mainView.collectionView) { base, keyboardHeight in
                base.contentInset.bottom = keyboardHeight > 0 ? keyboardHeight : 30.scale
            })
            .disposed(by: disposeBag)
        
        mainView.collectionView.mainDelegate = self
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
extension ExploreViewController {
    static func make() -> ExploreViewController {
        let vc = ExploreViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: ExploreCollectionDelegate
extension ExploreViewController: ExploreCollectionDelegate {
    func exploreCollectionDidTapped(category: Category) {
        AmplitudeManager.shared
            .logEvent(name: "Explore Tap", parameters: ["what": "categories"])
        
        let vc = ComicsByViewController.make(category: category)
        present(vc, animated: true)
    }
    
    func exploreCollectionDidTapped(comics: ComicsCover) {
        let vc: UIViewController

        let needPayment = !SessionManager().hasActiveSubscriptions()
        if needPayment && comics.paid {
            vc = PaygateViewController.make()
        } else {
            vc = ComicsViewController.make(comicsId: comics.id)
        }

        present(vc, animated: true)
    }
}

// MARK: Private
private extension ExploreViewController {
    func content(empty: Bool) {
        mainView.collectionView.isHidden = empty
        mainView.emptyView.isHidden = !empty
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
        mainView.collectionView.isHidden = activity
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
