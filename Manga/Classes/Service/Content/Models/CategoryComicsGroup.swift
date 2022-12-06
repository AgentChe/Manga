//
//  CategoryComicsGroup.swift
//  Manga
//
//  Created by Андрей Чернышев on 02.12.2022.
//

struct CategoryComicsGroup: Codable, Hashable {
    let category: Category
    let comics: [ComicsCover]
}
