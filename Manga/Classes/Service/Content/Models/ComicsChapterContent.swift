//
//  ComicsChapterContent.swift
//  Manga
//
//  Created by Андрей Чернышев on 27.03.2023.
//

import Foundation

enum ComicsChapterContent: Codable, Hashable {
    case images([URL])
    case pdf(URL)
}
