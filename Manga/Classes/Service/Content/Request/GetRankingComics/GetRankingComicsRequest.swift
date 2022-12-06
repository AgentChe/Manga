//
//  GetRankingComicsRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import Alamofire

struct GetRankingComicsRequest: APIRequestBody {
    let userToken: String
    let rankingId: Int
    
    var url: String {
        GlobalDefinitions.domain + "/api/ranking/comics"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "ranking_id": rankingId
        ]
    }
}
