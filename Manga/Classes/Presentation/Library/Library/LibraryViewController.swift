//
//  LibraryViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 22.07.2022.
//

import UIKit
import RxSwift

final class LibraryViewController: UIViewController {
    lazy var mainView = LibraryView()
    
    private lazy var viewModel = LibraryViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private let discoverComicsTapped: () -> Void
    
    private init(discoverComicsTapped: @escaping () -> Void) {
        self.discoverComicsTapped = discoverComicsTapped
        
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
        
        viewModel.emptyState
            .drive(Binder(self) { base, state in
                base.empty(state: state)
            })
            .disposed(by: disposeBag)
        
        mainView.emptyView.button.rx.tap
            .bind(to: Binder(self) { base, void in
                base.discoverComicsTapped()
            })
            .disposed(by: disposeBag)
        
        addFilterActions()
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension LibraryViewController {
    static func make(discoverComicsTapped: @escaping () -> Void) -> LibraryViewController {
        let vc = LibraryViewController(discoverComicsTapped: discoverComicsTapped)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: LibraryTableDelegate
extension LibraryViewController: LibraryTableDelegate {
    func libraryTableDidTapped(comics: ComicsCover) {
        let vc: UIViewController

        let needPayment = !SessionManager().hasActiveSubscriptions()
        if needPayment && comics.paid {
            vc = PaygateViewController.make()
        } else {
            vc = ComicsViewController.make(comicsId: comics.id)
        }

        present(vc, animated: true)
    }
    
    func libraryTableDidTappedMenu(comics: ComicsCover) {
        let vc = LibraryBookMenuViewController.make { [weak self] result in
            switch result {
            case .delete:
                self?.viewModel.didTapRemove.accept(comics)
            case .share:
                self?.share(url: comics.shareLink)
            }
        }
        present(vc, animated: false)
    }
}

// MARK: Private
private extension LibraryViewController {
    func addFilterActions() {
        Observable
            .merge(
                mainView.filterView.savedButton.rx.tap
                    .map { LibraryFilterView.Filter.saved },
                
                mainView.filterView.historyButton.rx.tap
                    .map { LibraryFilterView.Filter.history },
                
                mainView.filterView.downloadedButton.rx.tap
                    .map { LibraryFilterView.Filter.downloaded }
            )
            .startWith(.saved)
            .bind(to: Binder(self) { base, filter in
                base.mainView.filterView.filter = filter
                base.viewModel.filter.accept(filter)
                base.analytics(filter: filter)
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                mainView.filterView.savedButton.rx.tap
                    .map { LibraryEmptyView.State.saved },
                
                mainView.filterView.historyButton.rx.tap
                    .map { LibraryEmptyView.State.history },
                
                mainView.filterView.downloadedButton.rx.tap
                    .map { LibraryEmptyView.State.downloaded }
            )
            .startWith(.saved)
            .bind(to: Binder(self) { base, state in
                base.mainView.emptyView.update(at: state)
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
        if activity {
            mainView.emptyView.isHidden = true
        }
        mainView.tableView.isHidden = activity
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func empty(state: LibraryEmptyView.State?) {
        mainView.emptyView.isHidden = state == nil
        
        guard let state = state else {
            return
        }
        
        mainView.emptyView.update(at: state)
    }
    
    func share(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    func analytics(filter: LibraryFilterView.Filter) {
        switch filter {
        case .saved:
            AmplitudeManager.shared
                .logEvent(name: "Saved Screen")
        case .downloaded:
            AmplitudeManager.shared
                .logEvent(name: "Download Screen")
        case .history:
            AmplitudeManager.shared
                .logEvent(name: "My History Screen")
        }
    }
}
