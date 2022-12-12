//
//  HomeTableElement.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import CoreGraphics

enum HomeTableElement {
    case offset(CGFloat)
    case freeComics(HomeComicsCover)
    case comicsByCategory(HomeTableComicsByCategory)
    case comicsByRanking(HomeTableComicsByRanking)
    case comicsInProgress(HomeTableComicsInProgress)
    case title(String)
    case comicsNumber(HomeComicsNumber)
    case separator
    case categories([Category])
}

struct HomeComicsCover {
    let comics: ComicsCover
    let categories: [Category]
}

struct HomeTableComicsByCategory {
    let category: Category
    let comics: [HomeComicsCover]
    let canOpen: Bool
}

struct HomeTableComicsByRanking {
    let ranking: Ranking
    let comics: [HomeComicsCover]
    let canOpen: Bool
}

struct HomeTableComicsInProgress {
    let title: String
    let comics: [HomeComicsCover]
}

struct HomeComicsNumber {
    let number: String
    let comics: HomeComicsCover
}
