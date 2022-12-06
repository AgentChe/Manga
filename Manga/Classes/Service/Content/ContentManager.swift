//
//  ContentManager.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import RxSwift
import Foundation

protocol ContentManagerProtocol: AnyObject {
    func obtainCategories(forceUpdate: Bool) -> Single<[Category]>
    func obtainRankings(forceUpdate: Bool) -> Single<[Ranking]>
    func obtainComicsKit(comicsId: Int) -> Single<ComicsKit?>
    func obtainHomeKit() -> Single<HomeKit?>
    func save(comics: ComicsCover) -> Single<Bool>
    func removeSaved(comics: ComicsCover) -> Single<Bool>
    func obtainSavedComicsCover() -> Single<[ComicsCover]>
    func obtainExploreKit() -> Single<[ComicsCover]>
    func searchComics(at: String) -> Single<[ComicsCover]>
    func obtainCategoryComicsCover(categoryId: Int) -> Single<[ComicsCover]>
    func obtainRankingComicsCover(rankingId: Int) -> Single<[ComicsCover]>
    func obtainReadingComics() -> Single<[ComicsReadingProgress]>
    func set(comicsReadingProgress: ComicsReadingProgress) -> Single<Void>
    func removeComicsProgress(comicsId: Int) -> Single<Void>
}

final class ContentManager: ContentManagerProtocol {
    enum Constants {
        static let categoriesKey = "content_manager_categories_key"
        static let rankingKey = "content_manager_ranking_key"
        static let readingComicsKey = "content_manager_reading_comics_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension ContentManager {
    func obtainCategories(forceUpdate: Bool) -> Single<[Category]> {
        forceUpdate ? loadCategories() : cachedCategories()
    }
    
    func obtainRankings(forceUpdate: Bool) -> Single<[Ranking]> {
        forceUpdate ? loadRankings() : cachedRankings()
    }
    
    func obtainComicsKit(comicsId: Int) -> Single<ComicsKit?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetComicsKitRequest(userToken: userToken, comicsId: comicsId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetComicsKitResponse.map(from: $0) }
    }
    
    func obtainHomeKit() -> Single<HomeKit?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetHomeKitRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetHomeKitResponse.map(from: $0) }
    }
    
    func save(comics: ComicsCover) -> Single<Bool> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SaveComicsRequest(userToken: userToken, comicsId: comics.id)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { _ in true }
            .do(onSuccess: { success in
                if success {
                    ContentMediator.shared.notifyAboutSaved(comics: comics)
                }
            })
    }
    
    func removeSaved(comics: ComicsCover) -> Single<Bool> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = RemoveSavedComicsRequest(userToken: userToken, comicsId: comics.id)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { _ in true }
            .do(onSuccess: { success in
                if success {
                    ContentMediator.shared.notifyAboutRemoveSaved(comics: comics)
                }
            })
    }
    
    func obtainSavedComicsCover() -> Single<[ComicsCover]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetSavedComicsRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetSavedComicsResponse.map(from: $0) }
    }
    
    func obtainExploreKit() -> Single<[ComicsCover]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetExploreKitRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetExploreKitResponse.map(from: $0) }
    }
    
    func searchComics(at: String) -> Single<[ComicsCover]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SearchComicsRequest(userToken: userToken, search: at)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { SearchComicsResponse.map(from: $0) }
    }
    
    func obtainCategoryComicsCover(categoryId: Int) -> Single<[ComicsCover]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetCategoryComicsRequest(userToken: userToken, categoryId: categoryId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetCategoryComicsResponse.map(from: $0) }
    }
    
    func obtainRankingComicsCover(rankingId: Int) -> Single<[ComicsCover]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetRankingComicsRequest(userToken: userToken, rankingId: rankingId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetRankingComicsResponse.map(from: $0) }
    }
    
    func obtainReadingComics() -> Single<[ComicsReadingProgress]> {
        Single<[ComicsReadingProgress]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.readingComicsKey),
                let comics = try? JSONDecoder().decode([ComicsReadingProgress].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }
            
            event(.success(comics))
            
            return Disposables.create()
        }
    }
    
    func set(comicsReadingProgress: ComicsReadingProgress) -> Single<Void> {
        obtainReadingComics()
            .flatMap { readingComics -> Single<Void> in
                Single<Void>.create { event in
                    var result = readingComics
                    
                    if let index = result.firstIndex(where: { $0.comics.id == comicsReadingProgress.comics.id }) {
                        result[index] = comicsReadingProgress
                    } else {
                        result.append(comicsReadingProgress)
                    }
                    
                    if let data = try? JSONEncoder().encode(result) {
                        UserDefaults.standard.set(data, forKey: Constants.readingComicsKey)
                        
                        ContentMediator.shared.notifyAboutUpdate(comicsReadingProgress: comicsReadingProgress)
                    }
                    
                    event(.success(Void()))
                    
                    return Disposables.create()
                }
            }
    }
    
    func removeComicsProgress(comicsId: Int) -> Single<Void> {
        obtainReadingComics()
            .flatMap { readingComics -> Single<Void> in
                Single<Void>.create { event in
                    var result = readingComics
                    
                    if let index = result.firstIndex(where: { $0.comics.id == comicsId }) {
                        result.remove(at: index)
                        
                        if let data = try? JSONEncoder().encode(result) {
                            UserDefaults.standard.set(data, forKey: Constants.readingComicsKey)
                            
                            ContentMediator.shared.notifyAboutUpdateRemovedProgress(comicsId: comicsId)
                        }
                    }
                    
                    event(.success(Void()))
                    
                    return Disposables.create()
                }
            }
    }
}

// MARK: Private
private extension ContentManager {
    func loadCategories() -> Single<[Category]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetCategoriesRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetCategoriesResponse.map(from: $0) }
            .do(onSuccess: { categories in
                guard let data = try? JSONEncoder().encode(categories) else {
                    return
                }
                
                UserDefaults.standard.set(data, forKey: Constants.categoriesKey)
            })
    }
    
    func cachedCategories() -> Single<[Category]> {
        Single<[Category]>
            .create { event in
                guard let data = UserDefaults.standard.data(forKey: Constants.categoriesKey) else {
                    event(.success([]))
                    return Disposables.create()
                }
                
                let categories = try? JSONDecoder().decode([Category].self, from: data)
                
                event(.success(categories ?? []))
                
                return Disposables.create()
            }
    }
    
    func loadRankings() -> Single<[Ranking]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetRankingRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetRankingResponse.map(from: $0) }
            .do(onSuccess: { rankings in
                guard let data = try? JSONEncoder().encode(rankings) else {
                    return
                }
                
                UserDefaults.standard.set(data, forKey: Constants.rankingKey)
            })
    }
    
    func cachedRankings() -> Single<[Ranking]> {
        Single<[Ranking]>
            .create { event in
                guard let data = UserDefaults.standard.data(forKey: Constants.rankingKey) else {
                    event(.success([]))
                    return Disposables.create()
                }
                
                let rankings = try? JSONDecoder().decode([Ranking].self, from: data)
                
                event(.success(rankings ?? []))
                
                return Disposables.create()
            }
    }
}
