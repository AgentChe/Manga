//
//  GetComicsKitResponse.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

import UIKit

final class GetComicsKitResponse {
    static func map(from response: Any) -> ComicsKit? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any]
        else {
            return nil
        }
        
        guard
            let id = data["id"] as? Int,
            let name = data["name"] as? String,
            let imagePath = data["image"] as? String,
            let imageUrl = URL(string: imagePath),
            let rankingIds = data["ranking_ids"] as? [Int],
            let categoriesIds = data["categories_ids"] as? [Int],
            let shareLinkPath = data["link"] as? String,
            let shareLink = URL(string: shareLinkPath),
            let paid = data["paid"] as? Bool,
            let statusCode = data["state"] as? Int,
            let status = ComicsStatus(code: statusCode),
            let isTop5 = data["top5"] as? Bool,
            let isSaved = data["saved"] as? Bool,
            let whatAbout = data["what_about"] as? String,
            let creator = data["creator"] as? String
        else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let chaptersArray = data["chapters"] as? [[String: Any]] ?? []
        let chapters = chaptersArray.compactMap { chapterJSON -> ComicsChapter? in
            guard
                let dateString = chapterJSON["date"] as? String,
                let date = dateFormatter.date(from: dateString),
                let up = chapterJSON["up"] as? Bool,
                let sort = chapterJSON["sort"] as? Int,
                let contentArray = chapterJSON["content"] as? [[String: Any]]
            else {
                return nil
            }
            
            let content = contentArray.compactMap { contentJSON -> ComicsChapterContentBlock? in
                guard
                    let imageOriginalPath = contentJSON["image_original"] as? String,
                    let imageOriginalUrl = URL(string: imageOriginalPath),
                    let imagePlaceholderPath = contentJSON["image_placeholder"] as? String,
                    let imagePlaceholderUrl = URL(string: imagePlaceholderPath),
                    let imageHeight = contentJSON["image_height"] as? CGFloat
                else {
                    return nil
                }
                
                return ComicsChapterContentBlock(originalImageUrl: imageOriginalUrl,
                                                 placeholderImageUrl: imagePlaceholderUrl,
                                                 imageHeight: imageHeight)
            }
            
            return ComicsChapter(date: date,
                                 up: up,
                                 sort: sort,
                                 content: content)
        }
        
        let comics = Comics(id: id,
                            name: name,
                            imageUrl: imageUrl,
                            rankingIds: rankingIds,
                            categoriesIds: categoriesIds,
                            shareLink: shareLink,
                            paid: paid,
                            status: status,
                            isTop5: isTop5,
                            isSaved: isSaved,
                            whatAbout: whatAbout,
                            chapters: chapters,
                            creator: creator)
        
        let recommendationsJSON = data["recommendations"] as? [String: Any]
        let recommendations = map(rankingGroupJSON: recommendationsJSON ?? [:])
        
        return ComicsKit(comics: comics,
                         recommendations: recommendations)
    }
}

// MARK: Private
private extension GetComicsKitResponse {
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
