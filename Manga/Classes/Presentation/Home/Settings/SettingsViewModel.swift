//
//  SettingsViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 09.07.2022.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var didSelectReadingMode = PublishRelay<ReadingMode>()
    
    lazy var elements = makeElements()
    
    private lazy var readingMode = makeReadingMode()
    private lazy var activeSubscription = makeActiveSubscription()
    
    private lazy var profileManager = ProfileManager()
    private lazy var sessionManager = SessionManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension SettingsViewModel {
    func makeElements() -> Driver<[SettingsTableElement]> {
        Driver
            .combineLatest(activeSubscription, readingMode)
            .map { activeSubscription, readingMode -> [SettingsTableElement] in
                var result: [SettingsTableElement] = [
                    .readingMode(readingMode),
                    .offset(32.scale),
                    .contactUs("Settings.ContactUs".localized),
                    .offset(20.scale),
                    .separator,
                    .offset(20.scale),
                    .contactUs("Settings.PrivacyPolicy".localized),
                    .offset(20.scale),
                    .separator,
                    .offset(20.scale),
                    .contactUs("Settings.TermsOfUse".localized),
                ]
                
                if !activeSubscription {
                    result.append(contentsOf: [
                        .offset(60.scale),
                        .getAccess
                    ])
                }
                
                return result
            }
    }
    
    func makeReadingMode() -> Driver<ReadingMode> {
        let initial = profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.readingMode ?? .vertical }
            .asDriver(onErrorJustReturn: .vertical)
        
        let action = didSelectReadingMode
            .flatMapLatest { [weak self] readingMode -> Driver<ReadingMode> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    self.profileManager
                        .set(readingMode: readingMode.code)
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
                    .asDriver(onErrorDriveWith: .never())
                    .map { readingMode }
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, action)
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { [weak self] in
                guard let self = self else {
                    return false
                }
                
                return self.sessionManager.hasActiveSubscriptions()
            }
            .startWith(sessionManager.hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
