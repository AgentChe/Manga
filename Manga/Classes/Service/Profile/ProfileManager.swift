//
//  ProfileManager.swift
//  Manga
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import RxSwift

protocol ProfileManagerProtocol {
    func set(goal: Int,
             categories: [Int],
             pace: Int,
             time: Int,
             pushToken: String?,
             notificationsOptions: [Int]?) -> Single<Void>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension ProfileManager {
    func set(goal: Int,
             categories: [Int],
             pace: Int,
             time: Int,
             pushToken: String?,
             notificationsOptions: [Int]?) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SetRequest(userToken: userToken,
                                 goal: goal,
                                 categories: categories,
                                 pace: pace,
                                 time: time,
                                 pushToken: pushToken,
                                 notificationsOptions: notificationsOptions)
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
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
