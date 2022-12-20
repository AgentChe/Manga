//
//  ComicsViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import RxSwift
import RxCocoa

final class ComicsViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var didTapSeeAll = PublishRelay<Void>()
    lazy var didTapMark = PublishRelay<Bool>()
    lazy var didTapChapter = PublishRelay<ComicsChapter>()
    lazy var didTapRead = PublishRelay<Void>()
    lazy var didTapStartDownload = PublishRelay<Void>()
    lazy var didTapSort = PublishRelay<Void>()
    
    lazy var downloadState = makeDownloadState()
    lazy var reader = makeReader()
    lazy var shareLink = makeShareLink()
    lazy var inReading = makeInReading()
    lazy var isSavedComics = makeIsSavedComics()
    lazy var elements = makeElements()
    lazy var activity = RxActivityIndicator()
    
    private lazy var isShowingAll = makeIsShowingAll()
    private lazy var sort = makeSort()
    private lazy var readingProgress = makeReadingProgress()
    private lazy var categories = makeCategories()
    private lazy var comicsKit = makeComicsKit()
    private lazy var readingComics = makeReadingComics()
    private lazy var downloadComics = makeDownloadComics()
    
    private lazy var contentManager = ContentManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private let comicsId: BehaviorRelay<Int>
    
    init(comicsId: Int) {
        self.comicsId = BehaviorRelay(value: comicsId)
    }
}

// MARK: Private
private extension ComicsViewModel {
    func makeDownloadState() -> Driver<ComicsDownloadButton.State> {
        let initial = Observable
            .combineLatest(downloadComics.asObservable().take(1), comicsId)
            .map { downloadComics, comicsId -> ComicsDownloadButton.State in
                if downloadComics.contains(where: { $0.id == comicsId }) {
                    return .downloaded
                } else if DownloadComicsQueue.shared.containsOperation(with: comicsId) {
                    return .downloading
                } else {
                    return .download
                }
            }
            .asDriver(onErrorDriveWith: .never())
        
        let downloaded = ContentMediator.shared.comicsDidDownloaded
            .withLatestFrom(comicsId.asSignal(onErrorSignalWith: .never())) { ($0, $1) }
            .flatMap { downloadedComics, comicsId -> Driver<ComicsDownloadButton.State> in
                guard downloadedComics.id == comicsId else {
                    return .never()
                }
                
                return .just(.downloaded)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let startDownload = didTapStartDownload
            .withLatestFrom(comicsKit)
            .flatMapLatest { [weak self] comicsKit -> Observable<ComicsDownloadButton.State> in
                guard let self = self else {
                    return .never()
                }
                
                return self.contentManager
                    .download(comics: comicsKit.comics)
                    .asObservable()
                    .map { ComicsDownloadButton.State.downloading }
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver.merge(initial, downloaded, startDownload)
    }
    
    func makeReader() -> Driver<(Comics, ComicsChapter)> {
        let chapter = didTapChapter
            .withLatestFrom(comicsKit) { ($1.comics, $0) }
            .asDriver(onErrorDriveWith: .never())
        
        let read = didTapRead
            .withLatestFrom(comicsKit)
            .withLatestFrom(readingComics) { comicsKit, readingComics -> (Comics, ComicsChapter)? in
                let comics = comicsKit.comics
                let comicsChapter: ComicsChapter?
                
                if let lastReadingChapter = readingComics.first(where: { $0.comics.id == comics.id }) {
                    comicsChapter = comics.chapters[safe: lastReadingChapter.currentChapterIndex] ?? comics.chapters.last
                } else {
                    comicsChapter = comics.chapters.first
                }
                
                guard let comicsChapter = comicsChapter else {
                    return nil
                }

                return (comics, comicsChapter)
            }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver.merge(chapter, read)
    }
    
    func makeShareLink() -> Driver<URL> {
        comicsKit
            .map { $0.comics.shareLink }
    }
    
    func makeInReading() -> Driver<Bool> {
        readingProgress.map { $0 != nil }
    }
    
    func makeIsSavedComics() -> Driver<Bool> {
        let initial = comicsKit
            .map { $0.comics.isSaved }
        
        let action = didTapMark
            .withLatestFrom(comicsKit) { ($0, $1.comics) }
            .flatMapFirst { [weak self] isSaved, comics -> Observable<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Bool> {
                    let request = isSaved
                    ? self.contentManager.removeSaved(comics: ComicsCover(comics: comics))
                        : self.contentManager.save(comics: ComicsCover(comics: comics))

                    return request
                        .map { _ in !isSaved }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }

                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, action)
    }
    
    func makeElements() -> Driver<[ComicsTableElement]> {
        Driver
            .combineLatest(categories, comicsKit, isShowingAll, sort, readingProgress)
            .map { [weak self] categories, comicsKit, isShowingAll, sort, readingProgress -> [ComicsTableElement] in
                guard let self = self else {
                    return []
                }
                
                var result = [ComicsTableElement]()
                
                let comics = comicsKit.comics
                
                let coverElement = ComicsTableCoverElement(imageUrl: comics.imageUrl,
                                                           status: comics.status,
                                                           top5: comics.isTop5)
                result.append(.cover(coverElement))
                
                if let readingProgress = readingProgress {
                    result.append(contentsOf: [
                        .offset(36.scale),
                        .progress(readingProgress)
                    ])
                }
                
                let infoCategories = categories
                    .filter { category -> Bool in
                        comics.categoriesIds.contains(where: { category.id == $0 })
                    }
                    .map { $0.name }
                    .joined(separator: ", ")
                let infoElement = ComicsTableInfoElement(name: comics.name,
                                                         categories: infoCategories,
                                                         chaptersCount: comics.chapters.count)
                result.append(contentsOf: [
                    .offset(20.scale),
                    .info(infoElement),
                ])
                
                result
                    .append(contentsOf: [
                        .offset(30.scale),
                        .title("Comics.WhatAbout?".localized),
                        .offset(16.scale),
                        .whatAbout(comics.whatAbout)
                    ])
                
                result.append(contentsOf: [
                    .offset(30.scale),
                    .chaptersTitle
                ])
                
                let sortedChapters = self.sortChapters(comics.chapters, sortBy: sort)
                let chapters = isShowingAll ? sortedChapters : Array(sortedChapters.prefix(5))
                chapters.enumerated().forEach { index, chapter in
                    result.append(.offset(19.scale))
                    
                    let element = ComicsTableChapterElement(chapter: chapter.0, title: chapter.1)
                    result.append(.chapter(element))
                    
                    if (chapters.count - 1) != index {
                        result.append(contentsOf: [
                            .offset(18.scale),
                            .separator
                        ])
                    }
                }
                
                let needShowSeeAll = sortedChapters.count > 5 && !isShowingAll
                if needShowSeeAll {
                    result.append(contentsOf: [
                        .offset(26.scale),
                        .seeAll
                    ])
                }
                
                result.append(contentsOf: [
                    .offset(30.scale),
                    .title("Comics.Creator".localized),
                    .offset(16.scale),
                    .creator(comics.creator)
                ])
                
                if let recommendations = comicsKit.recommendations, !recommendations.comics.isEmpty {
                    let comics = recommendations.comics.map { comics -> HomeComicsCover in
                        let comicsCategories = self.categories(categories, in: comics)
                        return HomeComicsCover(comics: comics,
                                               categories: comicsCategories)
                    }
                    let block = HomeTableComicsByRanking(ranking: recommendations.ranking,
                                                         comics: comics,
                                                         canOpen: false)
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .block(block)
                    ])
                }
                
                let exploreCategories = categories
                    .filter { category -> Bool in
                        comics.categoriesIds.contains(where: { category.id == $0 })
                    }
                if !exploreCategories.isEmpty {
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .title("Comics.ExploreCategories".localized),
                        .offset(16.scale),
                        .exploreCategories(exploreCategories)
                    ])
                }
                
                return result
            }
    }
    
    func makeIsShowingAll() -> Driver<Bool> {
        didTapSeeAll
            .map { true }
            .startWith(false)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeSort() -> Driver<Sort> {
        didTapSort
            .scan(Sort.descending) { sort, void -> Sort in
                switch sort {
                case .ascending:
                    return .descending
                case .descending:
                    return .ascending
                }
            }
            .startWith(.descending)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeReadingProgress() -> Driver<Float?> {
        Driver
            .combineLatest(comicsKit, readingComics)
            .map { comicsKit, readingComics -> Float? in
                let comics = comicsKit.comics
                
                guard
                    !comics.chapters.isEmpty,
                    let reading = readingComics.first(where: { $0.comics.id == comics.id })
                else {
                    return nil
                }
                
                return reading.progress
            }
    }
    
    func makeCategories() -> Driver<[Category]> {
        contentManager
            .obtainCategories(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeComicsKit() -> Driver<ComicsKit> {
        comicsId
            .flatMapLatest { [weak self] comicsId -> Observable<ComicsKit> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<ComicsKit> {
                    self.contentManager
                        .obtainComicsKit(comicsId: comicsId)
                        .catchAndReturn(nil)
                        .flatMap { kit -> Single<ComicsKit> in
                            if let kit = kit {
                                return .just(kit)
                            }
                            
                            return .error(ContentError(.notContent))
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeReadingComics() -> Driver<[ComicsReadingProgress]> {
        let initial = contentManager
            .obtainReadingComics()
            .asDriver(onErrorJustReturn: [])
        
        let updated = ContentMediator.shared.comicsReadingProgressUpdated
            .flatMapLatest { [weak self] _ -> Driver<[ComicsReadingProgress]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.contentManager
                    .obtainReadingComics()
                    .asDriver(onErrorJustReturn: [])
            }
        
        return Driver.merge(initial, updated)
    }
    
    func makeDownloadComics() -> Driver<[Comics]> {
        let initial = contentManager
            .obtainDownloadComics()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { comics -> Driver<[Comics]> in
                ContentMediator.shared
                    .comicsDidDownloaded
                    .scan(comics) { result, comics -> [Comics] in
                        var copy = result
                        copy.append(comics)
                        return copy
                    }
                    .startWith(comics)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}

// MARK: Private (Additional)
private extension ComicsViewModel {
    enum Sort {
        case ascending
        case descending
    }
    
    func sortChapters(_ chapters: [ComicsChapter], sortBy: Sort) -> [(ComicsChapter, String)] {
        chapters
            .sorted(by: { $0.sort < $1.sort })
            .enumerated()
            .map { index, chapter -> (Int, ComicsChapter) in
                (index + 1, chapter)
            }
            .sorted(by: { comicsLeft, comicsRight -> Bool in
                switch sortBy {
                case .ascending:
                    return comicsLeft.0 < comicsRight.0
                case .descending:
                    return comicsLeft.0 > comicsRight.0
                }
            })
            .map { index, chapter -> (ComicsChapter, String) in
                (chapter, String(format: "Comics.ChapterNumber".localized, index))
            }
    }
    
    func categories(_ categories: [Category], in comics: ComicsCover) -> [Category] {
        categories.filter { category -> Bool in
            comics.categoriesIds.contains(where: { $0 == category.id })
        }
    }
}
