//
//  RemoveSavedComicsRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import Alamofire

struct RemoveSavedComicsRequest: APIRequestBody {
    let userToken: String
    let comicsId: Int
    
    var url: String {
        GlobalDefinitions.domain + "/api/v2/comics/remove"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "comics_id": comicsId
        ]
    }
}
