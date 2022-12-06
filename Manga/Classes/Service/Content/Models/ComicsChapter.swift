//
//  ComicsChapter.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import Foundation

struct ComicsChapter: Codable, Hashable {
    let date: Date
    let up: Bool
    let sort: Int
    let content: [ComicsChapterContentBlock]
}
