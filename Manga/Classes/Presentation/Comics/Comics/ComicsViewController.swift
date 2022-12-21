//
//  ComicsViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit
import RxSwift

final class ComicsViewController: UIViewController {
    lazy var mainView = ComicsView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = ComicsViewModel(comicsId: comicsId)
    
    private let comicsId: Int
    
    private init(comicsId: Int) {
        self.comicsId = comicsId
        
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
            .logEvent(name: "Book Screen")
        
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
                AmplitudeManager.shared
                    .logEvent(name: "Book Tap", parameters: ["what": "back"])
                
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.readButton.rx.tap
            .bind(to: viewModel.didTapRead)
            .disposed(by: disposeBag)
        
        viewModel.inReading
            .drive(Binder(mainView) { base, inReading in
                base.updateButton(at: inReading)
            })
            .disposed(by: disposeBag)
        
        mainView.downloadButton.rx.tap
            .withLatestFrom(viewModel.downloadState)
            .filter { $0 == .download }
            .mapToVoid()
            .do(onNext: {
                AmplitudeManager.shared
                    .logEvent(name: "Book Tap", parameters: ["what": "download"])
            })
            .bind(to: viewModel.didTapStartDownload)
            .disposed(by: disposeBag)
        
        viewModel.downloadState
            .drive(Binder(mainView.downloadButton) { base, state in
                base.downloadState = state
            })
            .disposed(by: disposeBag)
        
        viewModel.reader
            .drive(Binder(self) { base, reader in
                AmplitudeManager.shared
                    .logEvent(name: "Book Tap", parameters: ["what": "read"])
                
                let vc = ReaderViewController.make(comics: reader.0, chapter: reader.1)
                base.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.shareButton.rx.tap
            .withLatestFrom(viewModel.shareLink)
            .bind(to: Binder(self) { base, url in
                AmplitudeManager.shared
                    .logEvent(name: "Book Tap", parameters: ["what": "share"])
                
                base.share(url: url)
            })
            .disposed(by: disposeBag)
        
        mainView.favoriteButton.rx.tap
            .withLatestFrom(viewModel.isSavedComics)
            .do(onNext: { _ in
                AmplitudeManager.shared
                    .logEvent(name: "Book Tap", parameters: ["what": "bookmark"])
            })
            .bind(to: viewModel.didTapMark)
            .disposed(by: disposeBag)
        
        viewModel.isSavedComics
            .drive(Binder(self) { base, isSaved in
                base.update(favorite: isSaved)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension ComicsViewController {
    static func make(comicsId: Int) -> ComicsViewController {
        let vc = ComicsViewController(comicsId: comicsId)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: ComicsTableDelegate
extension ComicsViewController: ComicsTableDelegate {
    func comicsTableDidTapped(chapter: ComicsChapter) {
        viewModel.didTapChapter.accept(chapter)
    }
    
    func comicsTableDidTappedSeeAll() {
        viewModel.didTapSeeAll.accept(Void())
    }
    
    func comicsTableDidTapped(comics: ComicsCover) {
        let vc: UIViewController
        
        let needPayment = !SessionManager().hasActiveSubscriptions()
        if needPayment && comics.paid {
            vc = PaygateViewController.make()
        } else {
            vc = ComicsViewController.make(comicsId: comics.id)
        }
        
        present(vc, animated: true)
    }
    
    func comicsTableDidTapped(category: Category) {
        let vc = ComicsByViewController.make(category: category)
        present(vc, animated: true)
    }
    
    func comicsTableDidTappedSort() {
        viewModel.didTapSort.accept(Void())
    }
}

// MARK: Private
private extension ComicsViewController {
    func update(favorite: Bool) {
        let image = UIImage(named: favorite ? "Comics.Mark.Check" : "Comics.Mark.Uncheck")
        mainView.favoriteButton.iconView.image = image
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
    
    func share(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
    }
}
