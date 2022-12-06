//
//  GetSavedComicsRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import Alamofire

struct GetSavedComicsRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/comics/saved"
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
