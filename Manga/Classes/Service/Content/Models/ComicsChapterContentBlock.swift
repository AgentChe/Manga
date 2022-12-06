//
//  ComicsChapterContentBlock.swift
//  Manga
//
//  Created by Андрей Чернышев on 02.12.2022.
//

import UIKit

struct ComicsChapterContentBlock: Codable, Hashable {
    let originalImageUrl: URL
    let placeholderImageUrl: URL
    let imageHeight: CGFloat
}
