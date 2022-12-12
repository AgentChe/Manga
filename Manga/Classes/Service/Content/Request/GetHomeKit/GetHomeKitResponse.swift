//
//  GetHomeKitResponse.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import Foundation

final class GetHomeKitResponse {
    static func map(from response: Any) -> HomeKit? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let freeComicsJSON = data["free"] as? [String: Any],
            let freeComics = map(coverJSON: freeComicsJSON),
            let recommendationsJSON = data["recommendations"] as? [String: Any],
            let recommendations = map(rankingGroupJSON: recommendationsJSON),
            let dailyUpdatesJSON = data["daily_updates"] as? [String: Any],
            let dailyUpdates = map(rankingGroupJSON: dailyUpdatesJSON),
            let someCategoryJSON = data["some_category"] as? [String: Any],
            let someCategory = map(categoryGroupJSON: someCategoryJSON),
            let top5JSON = data["top5"] as? [String: Any],
            let top5 = map(rankingGroupJSON: top5JSON),
            let newReleasesJSON = data["new_releases"] as? [String: Any],
            let newReleases = map(rankingGroupJSON: newReleasesJSON)
        else {
            return nil
        }
        
        return HomeKit(freeComics: freeComics,
                       recommendations: recommendations,
                       dailyUpdates: dailyUpdates,
                       someCategory: someCategory,
                       top5: top5,
                       newReleases: newReleases)
    }
}

// MARK: Private
private extension GetHomeKitResponse {
    static func map(rankingGroupJSON: [String: Any]) -> RankingComicsGroup? {
        guard
            let rankingJSON = rankingGroupJSON["ranking"] as? [String: Any],
            let rankingId = rankingJSON["id"] as? Int,
            let rankingName = rankingJSON["name"] as? String,
            let coversArray = rankingGroupJSON["covers"] as? [[String: Any]]
        else {
            return nil
        }
        
        let ranking = Ranking(id: rankingId, name: rankingName)
        let covers = coversArray.compactMap { map(coverJSON: $0) }
        
        return RankingComicsGroup(ranking: ranking, comics: covers)
    }
    
    static func map(categoryGroupJSON: [String: Any]) -> CategoryComicsGroup? {
        guard
            let categoryJSON = categoryGroupJSON["category"] as? [String: Any],
            let categoryId = categoryJSON["id"] as? Int,
            let categoryName = categoryJSON["name"] as? String,
            let coversArray = categoryGroupJSON["covers"] as? [[String: Any]]
        else {
            return nil
        }
        
        let category = Category(id: categoryId, name: categoryName)
        let covers = coversArray.compactMap { map(coverJSON: $0) }
        
        return CategoryComicsGroup(category: category, comics: covers)
    }
    
    static func map(coverJSON: [String: Any]) -> ComicsCover? {
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
