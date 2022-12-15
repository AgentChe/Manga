//
//  ContentMediator.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import RxSwift
import RxCocoa

protocol ContentMediatorDelegate: AnyObject {
    func contentMediatorDidSaved(comics: ComicsCover)
    func contentMediatorDidRemovedSaved(comics: ComicsCover)
    func contentMediatorDidUpdated(comicsReadingProgress: ComicsReadingProgress)
    func contentMediatorDidRemovedProgress(comicsId: Int)
    func contentMediatorDidDownloaded(comics: Comics)
    func contentMediatorDidRemovedDownload(comicsId: Int)
}

final class ContentMediator {
    static let shared = ContentMediator()
    
    private var delegates = [Weak<ContentMediatorDelegate>]()
    
    private lazy var comicsDidSavedTrigger = PublishRelay<ComicsCover>()
    private lazy var comicsDidRemoveFromSavedTrigger = PublishRelay<ComicsCover>()
    private lazy var comicsReadingProgressUpdatedTrigger = PublishRelay<ComicsReadingProgress>()
    private lazy var comicsDidRemovedProgressTrigger = PublishRelay<Int>()
    private lazy var comicsDidDownloadedTrigger = PublishRelay<Comics>()
    private lazy var comicsDidRemovedDownloadTrigger = PublishRelay<Int>()
    
    private init() {}
}

// MARK: Public
extension ContentMediator {
    func notifyAboutSaved(comics: ComicsCover) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.contentMediatorDidSaved(comics: comics)
            }
            
            self?.comicsDidSavedTrigger.accept(comics)
        }
    }
    
    func notifyAboutRemoveSaved(comics: ComicsCover) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.contentMediatorDidRemovedSaved(comics: comics)
            }
            
            self?.comicsDidRemoveFromSavedTrigger.accept(comics)
        }
    }
    
    func notifyAboutUpdate(comicsReadingProgress: ComicsReadingProgress) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.contentMediatorDidUpdated(comicsReadingProgress: comicsReadingProgress)
            }
            
            self?.comicsReadingProgressUpdatedTrigger.accept(comicsReadingProgress)
        }
    }
    
    func notifyAboutUpdateRemovedProgress(comicsId: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.contentMediatorDidRemovedProgress(comicsId: comicsId)
            }
            
            self?.comicsDidRemovedProgressTrigger.accept(comicsId)
        }
    }
    
    func notifyAboutDownloaded(comics: Comics) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.contentMediatorDidDownloaded(comics: comics)
            }
            
            self?.comicsDidDownloadedTrigger.accept(comics)
        }
    }
    
    func notifyAboutRemoveDownload(comicsId: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.contentMediatorDidRemovedDownload(comicsId: comicsId)
            }
            
            self?.comicsDidRemovedDownloadTrigger.accept(comicsId)
        }
    }
}

// MARK: Public (Triggers)
extension ContentMediator {
    var comicsDidSaved: Signal<ComicsCover> {
        comicsDidSavedTrigger.asSignal()
    }
    
    var comicsDidRemoveFromSaved: Signal<ComicsCover> {
        comicsDidRemoveFromSavedTrigger.asSignal()
    }
    
    var comicsReadingProgressUpdated: Signal<ComicsReadingProgress> {
        comicsReadingProgressUpdatedTrigger.asSignal()
    }
    
    var comicsDidRemovedProgress: Signal<Int> {
        comicsDidRemovedProgressTrigger.asSignal()
    }
    
    var comicsDidDownloaded: Signal<Comics> {
        comicsDidDownloadedTrigger.asSignal()
    }
    
    var comicsDidRemoveDownload: Signal<Int> {
        comicsDidRemoveDownload.asSignal()
    }
}

// MARK: Public (Observer)
extension ContentMediator {
    func add(delegate: ContentMediatorDelegate) {
        let weakly = delegate as AnyObject
        delegates.append(Weak<ContentMediatorDelegate>(weakly))
        delegates = delegates.filter { $0.weak != nil }
    }
    
    func remove(delegate: ContentMediatorDelegate) {
        if let index = delegates.firstIndex(where: { $0.weak === delegate }) {
            delegates.remove(at: index)
        }
    }
}
