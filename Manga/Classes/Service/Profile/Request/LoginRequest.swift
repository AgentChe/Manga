//
//  LoginRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import Alamofire

struct LoginRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/v2/users/login"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "user_token": userToken
        ]
    }
}
