//
//  LibraryTableElement.swift
//  Manga
//
//  Created by Андрей Чернышев on 22.07.2022.
//

import CoreGraphics

enum LibraryTableElement {
    case offset(CGFloat)
    case comics(LibraryTableComicsElement)
    case separator
}

struct LibraryTableComicsElement {
    let comics: ComicsCover
    let categories: [Category]
    let progress: Float?
}
