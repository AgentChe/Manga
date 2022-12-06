//
//  ComicsReadingProgress.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

struct ComicsReadingProgress: Codable, Hashable {
    let comics: Comics
    let currentChapterIndex: Int
}

// MARK: Public
extension ComicsReadingProgress {
    var progress: Float {
        guard !comics.chapters.isEmpty else {
            return 0
        }
        
        let number = (currentChapterIndex + 1)
        return Float(number) / Float(comics.chapters.count)
    }
}
