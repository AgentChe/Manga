//
//  GetProfileResponse.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

enum GetProfileResponse {
    static func map(from response: Any) -> Profile? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any]
        else {
            return nil
        }
        
        return Profile(
            goal: data["goal"] as? Int,
            categories: data["categories"] as? [Int],
            pace: data["pace"] as? Int,
            time: data["time"] as? Int,
            notificationsOptions: data["notification_options"] as? [Int],
            readingMode: readingMode(from: data)
        )
    }
}

// MARK: Private
private extension GetProfileResponse {
    static func readingMode(from json: [String: Any]) -> ReadingMode? {
        guard let code = json["reading_mode"] as? String else {
            return nil
        }
        
        return ReadingMode(code: code)
    }
}
