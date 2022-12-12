//
//  ComicsCover.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import Foundation

struct ComicsCover: Codable, Hashable {
    let id: Int
    let name: String
    let imageUrl: URL
    let rankingIds: [Int]
    let categoriesIds: [Int]
    let shareLink: URL
    let paid: Bool
    let status: ComicsStatus
    let isTop5: Bool
}

// MARK: Make
extension ComicsCover {
    init(comics: Comics) {
        self.id = comics.id
        self.name = comics.name
        self.imageUrl = comics.imageUrl
        self.rankingIds = comics.rankingIds
        self.categoriesIds = comics.categoriesIds
        self.shareLink = comics.shareLink
        self.paid = comics.paid
        self.status = comics.status
        self.isTop5 = comics.isTop5
    }
}
