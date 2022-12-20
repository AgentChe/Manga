//
//  ChaptersTableElement.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import CoreGraphics

enum ChaptersTableElement {
    case offset
    case chapter(ChaptersTableChapterElement)
}

struct ChaptersTableChapterElement {
    let chapter: ComicsChapter
    let title: String
    let isSelected: Bool
    let separatorHidden: Bool
}
