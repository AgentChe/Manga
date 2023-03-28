//
//  ReaderViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import RxSwift
import RxCocoa

final class ReaderViewModel {
    let comics: BehaviorRelay<Comics>
    let didSelectChapter = PublishRelay<ComicsChapter>()
    
    lazy var title = makeTitle()
    lazy var shareLink = makeShareLink()
    lazy var progress = makeProgress()
    lazy var currentChapter = makeCurrentChapter()
    lazy var elements = makeElements()
    lazy var readingMode = makeReadingMode()
    
    private let startChapter: BehaviorRelay<ComicsChapter>
    
    private lazy var profileManager = ProfileManager()
    private lazy var contentManager = ContentManager()
    
    init(comics: Comics, startChapter: ComicsChapter) {
        self.comics = BehaviorRelay(value: comics)
        self.startChapter = BehaviorRelay(value: startChapter)
    }
}

// MARK: Private
private extension ReaderViewModel {
    func makeTitle() -> Driver<String> {
        Driver
            .combineLatest(
                comics.asDriver(),
                currentChapter.asDriver()
            )
            .map { comics, chapter -> String in
                let chapters = comics.chapters.sorted(by: { $0.sort < $1.sort })
                
                guard let index = chapters.firstIndex(of: chapter) else {
                    return ""
                }
                
                return String(format: "Reader.ChapterNumber".localized, index + 1)
            }
    }
    
    func makeShareLink() -> Driver<URL> {
        comics
            .map { $0.shareLink }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeProgress() -> Driver<Float> {
        Driver
            .combineLatest(
                comics.asDriver(),
                currentChapter.asDriver()
            )
            .flatMapLatest { [weak self] comics, chapter -> Driver<ComicsReadingProgress> in
                guard let self = self else {
                    return .never()
                }
                
                let chapters = comics.chapters.sorted(by: { $0.sort < $1.sort })
                
                guard let index = chapters.firstIndex(of: chapter) else {
                    return .never()
                }
                
                let readingComics = ComicsReadingProgress(comics: comics, currentChapterIndex: index)
                
                return self.contentManager
                    .set(comicsReadingProgress: readingComics)
                    .map { readingComics }
                    .asDriver(onErrorDriveWith: .never())
            }
            .map { readingComics -> Float in
                readingComics.progress
            }
    }
    
    func makeCurrentChapter() -> Driver<ComicsChapter> {
        Driver
            .merge(
                startChapter.asDriver(),
                didSelectChapter.asDriver(onErrorDriveWith: .never())
            )
            .distinctUntilChanged()
    }
    
    func makeElements() -> Driver<[ComicsChapter]> {
        comics.asDriver()
            .map { comics -> [ComicsChapter] in
                comics.chapters
                    .sorted(by: { $0.sort < $1.sort })
            }
    }
    
    func makeReadingMode() -> Driver<ReadingMode> {
        let initial = profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.readingMode ?? .vertical }
            .asDriver(onErrorJustReturn: .vertical)
        
        let updated = ProfileMediator.shared
            .didChangeReadingMode
            .asDriver(onErrorJustReturn: .vertical)
        
        return Driver
            .merge(initial, updated)
    }
}
