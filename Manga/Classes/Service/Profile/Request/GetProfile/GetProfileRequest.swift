//
//  GetProfileRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import Alamofire

struct GetProfileRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/v2/users/show"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}
