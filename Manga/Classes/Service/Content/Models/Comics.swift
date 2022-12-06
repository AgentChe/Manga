//
//  Comics.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import Foundation

struct Comics: Codable, Hashable {
    let id: Int
    let name: String
    let imageUrl: URL
    let rankingIds: [Int]
    let categoriesIds: [Int]
    let shareLink: URL
    let paid: Bool
    let status: ComicsStatus
    let isTop5: Bool
    let isSaved: Bool
    let whatAbout: String
    let chapters: [ComicsChapter]
    let creator: String
}
