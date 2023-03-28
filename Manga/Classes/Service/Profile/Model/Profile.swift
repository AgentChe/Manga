//
//  Profile.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

struct Profile: Codable, Hashable {
    let goal: Int?
    let categories: [Int]?
    let pace: Int?
    let time: Int?
    let notificationsOptions: [Int]?
    let readingMode: ReadingMode?
}
