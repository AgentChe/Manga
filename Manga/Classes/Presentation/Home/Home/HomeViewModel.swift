//
//  HomeViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import RxSwift
import RxCocoa

final class HomeViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var elements = makeElements()
    lazy var activity = RxActivityIndicator()
    
    private lazy var rankings = makeRankings()
    private lazy var categories = makeCategories()
    private lazy var comicsInProgress = makeComicsInProgress()
    private lazy var homeKit = makeHomeKit()
    
    private lazy var contentManager = ContentManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension HomeViewModel {
    func makeElements() -> Driver<[HomeTableElement]> {
        Driver
            .combineLatest(rankings, categories, comicsInProgress, homeKit)
            .map { [weak self] rankings, categories, comicsInProgress, kit -> [HomeTableElement] in
                guard let self = self else {
                    return []
                }
                
                var result = [HomeTableElement]()
                
                let freeComicsCategories = self.categories(categories, in: kit.freeComics)
                let freeComics = HomeComicsCover(comics: kit.freeComics, categories: freeComicsCategories)
                result.append(.freeComics(freeComics))
                
                if !kit.recommendations.comics.isEmpty {
                    let comics = kit.recommendations.comics.map { comics -> HomeComicsCover in
                        let comicsCategories = self.categories(categories, in: comics)
                        return HomeComicsCover(comics: comics,
                                               categories: comicsCategories)
                    }
                    let block = HomeTableComicsByRanking(ranking: kit.recommendations.ranking,
                                                         comics: comics,
                                                         canOpen: true)
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .comicsByRanking(block)
                    ])
                }
                
                if !kit.dailyUpdates.comics.isEmpty {
                    let comics = kit.dailyUpdates.comics.map { comics -> HomeComicsCover in
                        let comicsCategories = self.categories(categories, in: comics)
                        return HomeComicsCover(comics: comics,
                                               categories: comicsCategories)
                    }
                    let block = HomeTableComicsByRanking(ranking: kit.dailyUpdates.ranking,
                                                         comics: comics,
                                                         canOpen: true)
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .comicsByRanking(block)
                    ])
                }
                
                if !kit.someCategory.comics.isEmpty {
                    let comics = kit.someCategory.comics.map { comics -> HomeComicsCover in
                        let comicsCategories = self.categories(categories, in: comics)
                        return HomeComicsCover(comics: comics,
                                               categories: comicsCategories)
                    }
                    let block = HomeTableComicsByCategory(category: kit.someCategory.category,
                                                          comics: comics,
                                                          canOpen: true)
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .comicsByCategory(block)
                    ])
                }
                
                if !comicsInProgress.isEmpty {
                    let comics = comicsInProgress.map { comics -> HomeComicsCover in
                        let cover = ComicsCover(comics: comics.comics)
                        let comicsCategories = self.categories(categories, in: cover)
                        return HomeComicsCover(comics: cover,
                                               categories: comicsCategories)
                    }
                    let block = HomeTableComicsInProgress(title: "Home.ContinueToRead".localized,
                                                          comics: comics)
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .comicsInProgress(block)
                    ])
                }
                
                if !kit.top5.comics.isEmpty {
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .title(kit.top5.ranking.name),
                        .offset(24.scale)
                    ])
                    
                    kit.top5.comics.enumerated().forEach { index, comics in
                        let homeComicsCategories = self.categories(categories, in: comics)
                        let homeComics = HomeComicsCover(comics: comics,
                                                         categories: homeComicsCategories)
                        let comicsNumber = HomeComicsNumber(number: String(index + 1),
                                                            comics: homeComics)
                        result.append(.comicsNumber(comicsNumber))
                        
                        if (kit.top5.comics.count - 1) != index {
                            result.append(contentsOf: [
                                .offset(16.scale),
                                .separator,
                                .offset(16.scale)
                            ])
                        }
                    }
                }
                
                if !categories.isEmpty {
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .title("Home.Categories".localized),
                        .offset(16.scale),
                        .categories(categories)
                    ])
                }
                
                if !kit.newReleases.comics.isEmpty {
                    let comics = kit.newReleases.comics.map { comics -> HomeComicsCover in
                        let comicsCategories = self.categories(categories, in: comics)
                        return HomeComicsCover(comics: comics,
                                               categories: comicsCategories)
                    }
                    let block = HomeTableComicsByRanking(ranking: kit.newReleases.ranking,
                                                         comics: comics,
                                                         canOpen: false)
                    result.append(contentsOf: [
                        .offset(30.scale),
                        .comicsByRanking(block)
                    ])
                }
                
                return result
        }
    }
    
    func makeRankings() -> Driver<[Ranking]> {
        contentManager
            .obtainRankings(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeCategories() -> Driver<[Category]> {
        contentManager
            .obtainCategories(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeComicsInProgress() -> Driver<[ComicsReadingProgress]> {
        let initial = contentManager
            .obtainReadingComics()
            .asDriver(onErrorJustReturn: [])
        
        let updated = Signal
            .merge(
                ContentMediator.shared.comicsReadingProgressUpdated.map { _ in Void() },
                ContentMediator.shared.comicsDidRemovedProgress.map { _ in Void() }
            )
            .flatMapLatest { [weak self] void -> Driver<[ComicsReadingProgress]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.contentManager
                    .obtainReadingComics()
                    .asDriver(onErrorJustReturn: [])
            }
        
        return Driver.merge(initial, updated)
    }
    
    func makeHomeKit() -> Driver<HomeKit> {
        func source() -> Single<HomeKit> {
            contentManager
                .obtainHomeKit()
                .flatMap { kit -> Single<HomeKit> in
                    guard let kit = kit else {
                        return .error(ContentError(.notContent))
                    }
                    
                    return .just(kit)
                }
        }
        
        func trigger(error: Error) -> Observable<Void> {
            guard let tryAgain = self.tryAgain?(error) else {
                return .empty()
            }
            
            return tryAgain
        }
        
        return observableRetrySingle
            .retry(source: { source() },
                   trigger: { trigger(error: $0) })
            .trackActivity(activity)
            .asDriver(onErrorDriveWith: .never())
    }
}

// MARK: Private (Additional)
private extension HomeViewModel {
    func categories(_ categories: [Category], in comics: ComicsCover) -> [Category] {
        categories.filter { category -> Bool in
            comics.categoriesIds.contains(where: { $0 == category.id })
        }
    }
}
