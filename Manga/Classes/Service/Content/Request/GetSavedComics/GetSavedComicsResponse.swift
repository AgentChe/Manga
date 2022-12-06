//
//  GetSavedComicsResponse.swift.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import Foundation

final class GetSavedComicsResponse {
    static func map(from response: Any) -> [ComicsCover] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { coverJSON -> ComicsCover? in
            guard
                let id = coverJSON["id"] as? Int,
                let name = coverJSON["name"] as? String,
                let imagePath = coverJSON["image"] as? String,
                let imageUrl = URL(string: imagePath),
                let rankingIds = coverJSON["ranking_ids"] as? [Int],
                let categoriesIds = coverJSON["categories_ids"] as? [Int],
                let shareLinkPath = coverJSON["link"] as? String,
                let shareLink = URL(string: shareLinkPath),
                let paid = coverJSON["paid"] as? Bool,
                let statusCode = coverJSON["state"] as? Int,
                let status = ComicsStatus(code: statusCode),
                let isTop5 = coverJSON["top5"] as? Bool
            else {
                return nil
            }
            
            return ComicsCover(id: id,
                               name: name,
                               imageUrl: imageUrl,
                               rankingIds: rankingIds,
                               categoriesIds: categoriesIds,
                               shareLink: shareLink,
                               paid: paid,
                               status: status,
                               isTop5: isTop5)
        }
    }
}
