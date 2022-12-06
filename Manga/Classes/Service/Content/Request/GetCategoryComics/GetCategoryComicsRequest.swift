//
//  GetCategoryComicsRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import Alamofire

struct GetCategoryComicsRequest: APIRequestBody {
    let userToken: String
    let categoryId: Int
    
    var url: String {
        GlobalDefinitions.domain + "/api/category/comics"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "category_id": categoryId
        ]
    }
}
