//
//  ComicsByViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit
import RxSwift

final class ComicsByViewController: UIViewController {
    lazy var mainView = ComicsByView(title: titleString)
    
    private let viewModel: ComicsByViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private let titleString: String
    
    private init(category: Category) {
        self.viewModel = ComicsByViewModel(categoryId: category.id)
        self.titleString = category.name
        
        super.init(nibName: nil, bundle: nil)
    }
    
    private init(ranking: Ranking) {
        self.viewModel = ComicsByViewModel(rankingId: ranking.id)
        self.titleString = ranking.name
        
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
            .logEvent(name: "Category Screen")
        
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
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(mainView.collectionView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.collectionView.mainDelegate = self
    }
}

// MARK: Make
extension ComicsByViewController {
    static func make(category: Category) -> ComicsByViewController {
        let vc = ComicsByViewController(category: category)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    static func make(ranking: Ranking) -> ComicsByViewController {
        let vc = ComicsByViewController(ranking: ranking)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: ComicsByCollectionDelegate
extension ComicsByViewController: ComicsByCollectionDelegate {
    func comicsByCollectionTapped(comics: ComicsCover) {
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
private extension ComicsByViewController {
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
