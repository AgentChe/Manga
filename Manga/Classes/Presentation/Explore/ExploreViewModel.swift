//
//  ExploreViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 19.07.2022.
//

import RxSwift
import RxCocoa
import Kingfisher

final class ExploreViewModel {
    struct Result {
        let elements: [ExploreCollectionElement]
        let checkOnEmpty: Bool
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var userSearching = BehaviorRelay(value: false)
    lazy var search = BehaviorRelay(value: "")
    
    lazy var elements = makeElements()
    lazy var activity = RxActivityIndicator()
    
    private lazy var defaultsElements = makeDefaultElements()
    private lazy var source = makeSource()
    private lazy var defaultCovers = makeDefaultCovers()
    private lazy var categories = makeCategories()
    
    private lazy var contentManager = ContentManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension ExploreViewModel {
    enum Source: Equatable {
        case `default`
        case search(String)
        case empty
    }
    
    func makeElements() -> Driver<Result> {
        Driver
            .combineLatest(defaultsElements, source)
            .flatMapLatest { [weak self] defaultsElements, source -> Driver<Result> in
                guard let self = self else {
                    return .never()
                }
                
                switch source {
                case .default:
                    let result = Result(elements: defaultsElements, checkOnEmpty: false)
                    return .just(result)
                case .search(let text):
                    return self.makeSearchElements(text: text)
                        .map {
                            Result(elements: $0, checkOnEmpty: true)
                        }
                case .empty:
                    let result = Result(elements: [], checkOnEmpty: false)
                    return .just(result)
                }
            }
            .startWith(Result(elements: [], checkOnEmpty: false))
    }
    
    func makeSource() -> Driver<Source> {
        Driver
            .combineLatest(userSearching.asDriver(),
                           search.asDriver()
                            .debounce(RxTimeInterval.milliseconds(1000))
                            .startWith(""))
            .map { userSearching, search -> Source in
                guard userSearching else {
                    return .default
                }
                
                return search.isEmpty ? .empty : .search(search)
            }
            .distinctUntilChanged()
    }
    
    func makeDefaultElements() -> Driver<[ExploreCollectionElement]> {
        Driver
            .combineLatest(categories, defaultCovers)
            .map { [weak self] categories, defaultCovers -> [ExploreCollectionElement] in
                guard let self = self else {
                    return []
                }
                
                var result = [ExploreCollectionElement]()
                
                result.append(contentsOf: [
                    .title("Explore.ExploreCategories".localized),
                    .verticalOffset(16.scale),
                    .categories(categories),
                    .verticalOffset(30.scale),
                    .title("Explore.TrendingSearches".localized)
                ])
                
                if !defaultCovers.isEmpty {
                    defaultCovers.forEach { comics in
                        let comicsCategories = self.categories(categories, in: comics)
                        let cover = ExploreComicsCover(comics: comics,
                                                       categories: comicsCategories)
                        let element =  ExploreCollectionElement.comics(cover)
                        result.append(element)
                    }
                }
                
                return result
            }
    }
    
    func makeSearchElements(text: String) -> Driver<[ExploreCollectionElement]> {
        Driver
            .combineLatest(categories, makeSearchComics(text: text))
            .map { [weak self] categories, comics -> [ExploreCollectionElement] in
                guard let self = self else {
                    return []
                }
                
                return comics.map { comics -> ExploreCollectionElement in
                    let comicsCategories = self.categories(categories, in: comics)
                    let cover = ExploreComicsCover(comics: comics,
                                                   categories: comicsCategories)
                    return ExploreCollectionElement.comics(cover)
                }
            }
    }
    
    func makeSearchComics(text: String) -> Driver<[ComicsCover]> {
        func source() -> Single<[ComicsCover]> {
            contentManager
                .searchComics(at: text)
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
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeDefaultCovers() -> Driver<[ComicsCover]> {
        func source() -> Single<[ComicsCover]> {
            contentManager
                .obtainExploreKit()
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
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeCategories() -> Driver<[Category]> {
        contentManager
            .obtainCategories(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}

// MARK: Private (Additional)
private extension ExploreViewModel {
    func categories(_ categories: [Category], in comics: ComicsCover) -> [Category] {
        categories.filter { category -> Bool in
            comics.categoriesIds.contains(where: { $0 == category.id })
        }
    }
}
