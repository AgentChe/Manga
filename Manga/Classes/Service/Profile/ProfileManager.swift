//
//  ProfileManager.swift
//  Manga
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import RxSwift

protocol ProfileManagerProtocol {
    func set(goal: Int?,
             categories: [Int]?,
             pace: Int?,
             time: Int?,
             pushToken: String?,
             notificationsOptions: [Int]?,
             readingMode: String?) -> Single<Void>
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    enum Constants {
        static let goalKey = "profile_manager_goal_key"
        static let categoriesKey = "profile_manager_categories_key"
        static let paceKey = "profile_manager_pace_key"
        static let timeKey = "profile_manager_time_key"
        static let notificationsOptionsKey = "profile_manager_notifications_options_key"
        static let readingModeKey = "profile_manager_reading_mode_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension ProfileManager {
    func set(goal: Int? = nil,
             categories: [Int]? = nil,
             pace: Int? = nil,
             time: Int? = nil,
             pushToken: String? = nil,
             notificationsOptions: [Int]? = nil,
             readingMode: String? = nil) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SetRequest(userToken: userToken,
                                 goal: goal,
                                 categories: categories,
                                 pace: pace,
                                 time: time,
                                 pushToken: pushToken,
                                 notificationsOptions: notificationsOptions,
                                 readingMode: readingMode)
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: { [weak self] in
                self?.store(goal: goal)
                self?.store(categories: categories)
                self?.store(pace: pace)
                self?.store(time: time)
                self?.store(notificationsOptions: notificationsOptions)
                self?.store(readingModeCode: readingMode)
            })
    }
    
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?> {
        forceUpdate ? loadProfile() : cachedProfile()
    }
    
    func syncTokens(oldToken: String, newToken: String) -> Single<Void> {
        let request = SyncTokensRequest(oldToken: oldToken,
                                        newToken: newToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func login(userToken: String) -> Single<Void> {
        let request = LoginRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
}

// MARK: Private
private extension ProfileManager {
    func loadProfile() -> Single<Profile?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetProfileRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetProfileResponse.map(from: $0) }
            .do(onSuccess: { [weak self] profile in
                self?.store(goal: profile?.goal)
                self?.store(categories: profile?.categories)
                self?.store(pace: profile?.pace)
                self?.store(time: profile?.time)
                self?.store(notificationsOptions: profile?.notificationsOptions)
                self?.store(readingModeCode: profile?.readingMode?.code)
            })
    }
    
    func cachedProfile() -> Single<Profile?> {
        Single<Profile?>.create { event in
            let goal = UserDefaults.standard.value(forKey: Constants.goalKey) as? Int
            let categories = UserDefaults.standard.value(forKey: Constants.categoriesKey) as? [Int]
            let pace = UserDefaults.standard.value(forKey: Constants.paceKey) as? Int
            let time = UserDefaults.standard.value(forKey: Constants.timeKey) as? Int
            let notificationsOptions = UserDefaults.standard.value(forKey: Constants.notificationsOptionsKey) as? [Int]
            let readingModeCode = UserDefaults.standard.value(forKey: Constants.readingModeKey) as? String
            let readingMode = ReadingMode(code: readingModeCode ?? "")
            
            let profile = Profile(
                goal: goal,
                categories: categories,
                pace: pace,
                time: time,
                notificationsOptions: notificationsOptions,
                readingMode: readingMode
            )
            
            event(.success(profile))
            
            return Disposables.create()
        }
    }
    
    func store(goal: Int?) {
        guard let goal = goal else {
            return
        }
        
        UserDefaults.standard.set(goal, forKey: Constants.goalKey)
        
        ProfileMediator.shared.didChange(goal: goal)
    }
    
    func store(categories: [Int]?) {
        guard let categories = categories else {
            return
        }
        
        UserDefaults.standard.set(categories, forKey: Constants.categoriesKey)
        
        ProfileMediator.shared.didChange(categories: categories)
    }
    
    func store(pace: Int?) {
        guard let pace = pace else {
            return
        }
        
        UserDefaults.standard.set(pace, forKey: Constants.paceKey)
        
        ProfileMediator.shared.didChange(pace: pace)
    }
    
    func store(time: Int?) {
        guard let time = time else {
            return
        }
        
        UserDefaults.standard.set(time, forKey: Constants.timeKey)
        
        ProfileMediator.shared.didChange(time: time)
    }
    
    func store(notificationsOptions: [Int]?) {
        guard let notificationsOptions = notificationsOptions else {
            return
        }
        
        UserDefaults.standard.set(notificationsOptions, forKey: Constants.notificationsOptionsKey)
        
        ProfileMediator.shared.didChange(notificationsOptions: notificationsOptions)
    }
    
    func store(readingModeCode: String?) {
        guard let readingModeCode = readingModeCode, let readingMode = ReadingMode(code: readingModeCode) else {
            return
        }
        
        UserDefaults.standard.set(readingModeCode, forKey: Constants.readingModeKey)
        
        ProfileMediator.shared.didChange(readingMode: readingMode)
    }
}
