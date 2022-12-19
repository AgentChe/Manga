//
//  ComicsTableElement.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import CoreGraphics
import Foundation

enum ComicsTableElement {
    case offset(CGFloat)
    case cover(ComicsTableCoverElement)
    case progress(Float)
    case info(ComicsTableInfoElement)
    case title(String)
    case whatAbout(String)
    case chaptersTitle
    case chapter(ComicsTableChapterElement)
    case separator
    case seeAll
    case creator(String)
    case block(HomeTableComicsByRanking)
    case exploreCategories([Category])
}

struct ComicsTableCoverElement {
    let imageUrl: URL
    let status: ComicsStatus
    let top5: Bool
}

struct ComicsTableInfoElement {
    let name: String
    let categories: String
    let chaptersCount: Int
}

struct ComicsTableChapterElement {
    let chapter: ComicsChapter
    let title: String
}
