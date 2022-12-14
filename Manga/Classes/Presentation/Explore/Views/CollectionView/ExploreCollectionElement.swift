//
//  ExploreCollectionElement.swift
//  Manga
//
//  Created by Андрей Чернышев on 19.07.2022.
//

import CoreGraphics

enum ExploreCollectionElement {
    case verticalOffset(CGFloat)
    case title(String)
    case categories([Category])
    case comics(ExploreComicsCover)
}

struct ExploreComicsCover {
    let comics: ComicsCover
    let categories: [Category]
}
