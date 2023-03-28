//
//  SetRequest.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.08.2022.
//

import Alamofire

struct SetRequest: APIRequestBody {
    let userToken: String
    let goal: Int?
    let categories: [Int]?
    let pace: Int?
    let time: Int?
    let pushToken: String?
    let notificationsOptions: [Int]?
    let readingMode: String?
    
    var url: String {
        GlobalDefinitions.domain + "/api/v2/users/set"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ] as [String : Any]
        
        if let goal = goal {
            params["goal"] = goal
        }
        
        if let categories = categories {
            params["categories"] = categories
        }
        
        if let pace = pace {
            params["pace"] = pace
        }
        
        if let time = time {
            params["time"] = time
        }
        
        if let pushToken = pushToken {
            params["notification_key"] = pushToken
        }
        
        if let notificationsOptions = notificationsOptions {
            params["notification_options"] = notificationsOptions
        }
        
        if let readingMode = readingMode {
            params["reading_mode"] = readingMode
        }
        
        return params
    }
}
