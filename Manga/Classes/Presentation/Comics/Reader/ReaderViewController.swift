//
//  ReaderViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import UIKit
import RxSwift

final class ReaderViewController: UIViewController {
    lazy var mainView = ReaderView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let viewModel: ReaderViewModel
    
    private init(comics: Comics, chapter: ComicsChapter) {
        viewModel = ReaderViewModel(comics: comics, startChapter: chapter)
        
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
            .logEvent(name: "Read Screen")
        
        mainView.navView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                AmplitudeManager.shared
                    .logEvent(name: "Read Tap", parameters: ["what": "close"])
                
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.navView.chaptersButton.rx.tap
            .withLatestFrom(viewModel.comics)
            .withLatestFrom(viewModel.currentChapter) { ($0, $1) }
            .bind(to: Binder(self) { base, args in
                AmplitudeManager.shared
                    .logEvent(name: "Read Tap", parameters: ["what": "chapters"])
                
                base.open(chapters: args.0.chapters, currentChapter: args.1)
            })
            .disposed(by: disposeBag)
        
        viewModel.elements
            .withLatestFrom(viewModel.currentChapter) { ($0, $1) }
            .drive(Binder(mainView.collectionView) { base, args in
                base.setup(elements: args.0, scrollTo: args.1)
            })
            .disposed(by: disposeBag)
        
        mainView.bottomView.shareButton.rx.tap
            .withLatestFrom(viewModel.shareLink)
            .bind(to: Binder(self) { base, url in
                AmplitudeManager.shared
                    .logEvent(name: "Read Tap", parameters: ["what": "share"])
                
                base.share(url: url)
            })
            .disposed(by: disposeBag)
        
        mainView.bottomView.markFinishButton.rx.tap
            .bind(to: Binder(self) { base, void in
                AmplitudeManager.shared
                    .logEvent(name: "Read Tap", parameters: ["what": "mark as finished"])
                
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.title
            .drive(Binder(mainView) { base, title in
                base.setup(title: title)
            })
            .disposed(by: disposeBag)
        
        viewModel.progress
            .drive(Binder(mainView.progressView) { base, progress in
                base.setProgress(progress, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLastChapter
            .drive(Binder(mainView) { base, isLastChapter in
                base.bottomView(hidden: !isLastChapter)
            })
            .disposed(by: disposeBag)
        
        viewModel.currentChapter
            .drive(Binder(mainView.collectionView) { base, step in
                base.scroll(to: step)
            })
            .disposed(by: disposeBag)
        
        mainView.collectionView.mainDelegate = self
    }
}

// MARK: Make
extension ReaderViewController {
    static func make(comics: Comics, chapter: ComicsChapter) -> ReaderViewController {
        let vc = ReaderViewController(comics: comics, chapter: chapter)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: ReaderCollectionDelegate
extension ReaderViewController: ReaderCollectionDelegate {
    func readerCollectionDidChanged(chapter: ComicsChapter) {
        viewModel.didSelectChapter.accept(chapter)
    }
}

// MARK: Private
private extension ReaderViewController {
    func share(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    func open(chapters: [ComicsChapter], currentChapter: ComicsChapter) {
        let vc = ChaptersViewController.make(chapters: chapters, selectedChapter: currentChapter) { [weak self] chapter in
            self?.viewModel.didSelectChapter.accept(chapter)
        }
        present(vc, animated: true)
    }
}
