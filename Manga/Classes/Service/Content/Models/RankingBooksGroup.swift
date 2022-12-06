//
//  RankingComicsGroup.swift
//  Manga
//
//  Created by Андрей Чернышев on 13.07.2022.
//

struct RankingComicsGroup: Codable, Hashable {
    let ranking: Ranking
    let comics: [ComicsCover]
}
