//
//  HomeKit.swift
//  Manga
//
//  Created by Андрей Чернышев on 12.07.2022.
//

struct HomeKit: Codable, Hashable {
    let freeComics: ComicsCover
    let recommendations: RankingComicsGroup
    let dailyUpdates: RankingComicsGroup
    let someCategory: CategoryComicsGroup
    let top5: RankingComicsGroup
    let newReleases: RankingComicsGroup
}
