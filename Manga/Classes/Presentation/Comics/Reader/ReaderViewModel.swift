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
    let currentChapter: BehaviorRelay<ComicsChapter>
    
    lazy var title = makeTitle()
    lazy var elements = makeElements()
    lazy var shareLink = makeShareLink()
    lazy var progress = makeProgress()
    lazy var isLastChapter = makeIsLastChapter()
    
    private lazy var contentManager = ContentManager()
    
    init(comics: Comics, startChapter: ComicsChapter) {
        self.comics = BehaviorRelay(value: comics)
        self.currentChapter = BehaviorRelay(value: startChapter)
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
    
    func makeElements() -> Driver<[ComicsChapterContentBlock]> {
        currentChapter
            .asDriver()
            .map { $0.content }
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
    
    func makeIsLastChapter() -> Driver<Bool> {
        Driver
            .combineLatest(
                comics.asDriver(),
                currentChapter.asDriver()
            )
            .map { comics, chapter -> Bool in
                let chapters = comics.chapters.sorted(by: { $0.sort < $1.sort })
                
                guard let index = chapters.firstIndex(of: chapter) else {
                    return true
                }
                
                return (chapters.count - 1) == index
            }
    }
}
