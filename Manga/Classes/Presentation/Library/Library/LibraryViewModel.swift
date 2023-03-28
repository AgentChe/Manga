//
//  LibraryViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 22.07.2022.
//

import RxSwift
import RxCocoa

final class LibraryViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var filter = PublishRelay<LibraryFilterView.Filter>()
    lazy var didTapRemove = PublishRelay<ComicsCover>()
    
    lazy var elements = makeElements()
    lazy var emptyState = makeEmptyState()
    lazy var activity = RxActivityIndicator()
    
    private lazy var comicsElements = makeComicsElements()
    private lazy var savedComicsElements = makeSavedComicsElements()
    private lazy var historyComicsElements = makeHistoryComicsElements()
    private lazy var readingComics = makeReadingComics()
    private lazy var categories = makeCategories()
    
    private lazy var contentManager = ContentManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension LibraryViewModel {
    func makeEmptyState() -> Driver<LibraryEmptyView.State?> {
        elements
            .withLatestFrom(filter.asDriver(onErrorDriveWith: .never())) { ($0, $1) }
            .map { elements, filter -> LibraryEmptyView.State? in
                guard elements.isEmpty else {
                    return nil
                }
                
                switch filter {
                case .saved:
                    return .saved
                case .history:
                    return .history
                }
            }
            .startWith(nil)
    }
    
    func makeElements() -> Driver<[LibraryTableElement]> {
        comicsElements
            .map { comicsElements -> [LibraryTableElement] in
                var result = [LibraryTableElement]()
                
                comicsElements.enumerated().forEach { index, comicsElement in
                    result.append(.comics(comicsElement))
                    
                    if (comicsElements.count - 1) != index {
                        result.append(contentsOf: [
                            .offset(16.scale),
                            .separator,
                            .offset(16.scale)
                        ])
                    }
                }
                
                return result
            }
    }
    
    func makeComicsElements() -> Driver<[LibraryTableComicsElement]> {
        filter.asDriver(onErrorDriveWith: .never())
            .flatMapLatest { [weak self] filter -> Driver<[LibraryTableComicsElement]> in
                guard let self = self else {
                    return .never()
                }
                
                switch filter {
                case .saved:
                    return self.savedComicsElements
                case .history:
                    return self.historyComicsElements
                }
            }
    }
    
    func makeSavedComicsElements() -> Driver<[LibraryTableComicsElement]> {
        let savedComics = downloadSavedComics()
            .flatMapLatest { [weak self] comics -> Driver<[ComicsCover]> in
                guard let self = self else {
                    return .never()
                }
                
                let saved = ContentMediator.shared
                    .comicsDidSaved
                    .map { (1, $0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let removed = ContentMediator.shared
                    .comicsDidRemoveFromSaved
                    .map { (2, $0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let libraryDelete = self.didTapRemove
                    .flatMapLatest { comics -> Single<(Int, ComicsCover)> in
                        self.contentManager
                            .removeSaved(comics: comics)
                            .map { success in (2, comics) }
                    }
                    .asDriver(onErrorDriveWith: .never())
                
                return Driver
                    .merge(saved, removed, libraryDelete)
                    .scan(comics) { array, args -> [ComicsCover] in
                        let (action, comics) = args
                        
                        var copy = array
                        
                        if action == 1 {
                            if let index = copy.firstIndex(where: { $0.id == comics.id }) {
                                copy[index] = comics
                            } else {
                                copy.append(comics)
                            }
                        } else if action == 2 {
                            if let index = copy.firstIndex(where: { $0.id == comics.id }) {
                                copy.remove(at: index)
                            }
                        }
                        
                        return copy
                    }
                    .startWith(comics)
            }
        
        return Driver
            .combineLatest(savedComics, readingComics, categories)
            .map { savedComics, readingComics, categories -> [LibraryTableComicsElement] in
                Self.combine(comicsCovers: savedComics, readingComics: readingComics, categories: categories)
            }
    }
    
    func makeHistoryComicsElements() -> Driver<[LibraryTableComicsElement]> {
        Driver
            .combineLatest(readingComics, categories)
            .map { readingComics, categories -> [LibraryTableComicsElement] in
                readingComics.map { reading -> LibraryTableComicsElement in
                    LibraryTableComicsElement(comics: ComicsCover(comics: reading.comics),
                                              categories: categories,
                                              progress: reading.progress)
                }
            }
    }
    
    func makeReadingComics() -> Driver<[ComicsReadingProgress]> {
        contentManager
            .obtainReadingComics()
            .asDriver(onErrorJustReturn: [])
            .flatMapLatest { [weak self] readingComics -> Driver<[ComicsReadingProgress]> in
                guard let self = self else {
                    return .never()
                }
                
                let updated = ContentMediator.shared
                    .comicsReadingProgressUpdated
                    .map { (1, $0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let libraryDelete = self.didTapRemove
                    .flatMapLatest { comics -> Single<(Int, ComicsReadingProgress)> in
                        self.contentManager
                            .removeComicsProgress(comicsId: comics.id)
                            .map { (2, ComicsReadingProgress(comics: Comics(id: comics.id), currentChapterIndex: 0)) }
                    }
                    .asDriver(onErrorDriveWith: .never())
                
                return Driver
                    .merge(updated, libraryDelete)
                    .scan(readingComics) { comics, args -> [ComicsReadingProgress] in
                        let (action, readingComics) = args
                        
                        var copy = comics
                        
                        if action == 1 {
                            if let index = copy.firstIndex(where: { $0.comics.id == readingComics.comics.id }) {
                                copy[index] = readingComics
                            } else {
                                copy.append(readingComics)
                            }
                        } else if action == 2 {
                            if let index = copy.firstIndex(where: { $0.comics.id == readingComics.comics.id }) {
                                copy.remove(at: index)
                            }
                        }
                        
                        return copy
                    }
                    .startWith(readingComics)
            }
    }
    
    func downloadSavedComics() -> Driver<[ComicsCover]> {
        func source() -> Single<[ComicsCover]> {
            contentManager
                .obtainSavedComicsCover()
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
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeCategories() -> Driver<[Category]> {
        contentManager
            .obtainCategories(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}

// MARK: Additional
private extension LibraryViewModel {
    static func combine(comicsCovers: [ComicsCover], readingComics: [ComicsReadingProgress], categories: [Category]) -> [LibraryTableComicsElement] {
        comicsCovers.map { comics -> LibraryTableComicsElement in
            let element = readingComics.first(where: { $0.comics.id == comics.id })
            
            let comicsCategories = categories.filter { category -> Bool in
                comics.categoriesIds.contains(where: { $0 == category.id })
            }

            return LibraryTableComicsElement(comics: comics,
                                             categories: comicsCategories,
                                             progress: element?.progress)
        }
    }
}

// MARK: Additional (Comics)
private extension Comics {
    init(id: Int) {
        self.id = id
        name = ""
        imageUrl = URL(string: "www.google.com")!
        rankingIds = []
        categoriesIds = []
        shareLink = URL(string: "www.google.com")!
        paid = false
        status = .none
        isTop5 = false
        isSaved = false
        whatAbout = ""
        chapters = []
        creator = ""
    }
}
