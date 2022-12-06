//
//  ComicsKit.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

struct ComicsKit: Codable, Hashable {
    let comics: Comics
    let recommendations: RankingComicsGroup?
}
