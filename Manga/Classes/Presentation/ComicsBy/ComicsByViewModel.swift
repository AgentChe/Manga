//
//  ComicsByViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import RxSwift
import RxCocoa

final class ComicsByViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var elements = makeElements()
    lazy var activity = RxActivityIndicator()
    
    private lazy var contentManager = ContentManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private lazy var comics = makeComics()
    private lazy var categories = makeCategories()
    
    private let source: BehaviorRelay<Source>
    
    init(categoryId: Int) {
        self.source = BehaviorRelay(value: .categories(categoryId))
    }
    
    init(rankingId: Int) {
        self.source = BehaviorRelay(value: .ranking(rankingId))
    }
}

// MARK: Private
private extension ComicsByViewModel {
    func makeElements() -> Driver<[ComicsByCollectionElement]> {
        Driver
            .combineLatest(comics, categories) { [weak self] comics, categories -> [ComicsByCollectionElement] in
                guard let self = self else {
                    return []
                }
                
                return comics.map { comics -> ComicsByCollectionElement in
                    let comicsCategories = self.categories(categories, in: comics)
                    return ComicsByCollectionElement(comics: comics,
                                                     categories: comicsCategories)
                }
            }
    }
    
    func makeComics() -> Driver<[ComicsCover]> {
        source
            .flatMapLatest { [weak self] sourceBy -> Observable<[ComicsCover]> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<[ComicsCover]> {
                    switch sourceBy {
                    case .categories(let id):
                        return self.contentManager
                            .obtainCategoryComicsCover(categoryId: id)
                    case .ranking(let id):
                        return self.contentManager
                            .obtainRankingComicsCover(rankingId: id)
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
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeCategories() -> Driver<[Category]> {
        contentManager
            .obtainCategories(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}

// MARK: Private (Additional)
private extension ComicsByViewModel {
    enum Source {
        case categories(Int)
        case ranking(Int)
    }
    
    func categories(_ categories: [Category], in comics: ComicsCover) -> [Category] {
        categories.filter { category -> Bool in
            comics.categoriesIds.contains(where: { $0 == category.id })
        }
    }
}
