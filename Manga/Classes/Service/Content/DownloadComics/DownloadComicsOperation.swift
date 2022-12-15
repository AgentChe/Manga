//
//  DownloadComicsOperation.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.12.2022.
//

import Kingfisher
import Foundation

final class DownloadComicsOperation {
    init(comics: Comics, completion: @escaping () -> Void) {
        download(comics: comics, completion: completion)
    }
}

// MARK: Private
private extension DownloadComicsOperation {
    func download(comics: Comics, completion: @escaping () -> Void) {
        let urls = urls(from: comics)
        download(imageUrls: urls, completion: completion)
    }
    
    func download(imageUrls: [URL], completion: @escaping () -> Void) {
        var urls = imageUrls
        
        let url = urls.removeFirst()
        
        KingfisherManager.shared.retrieveImage(with: url, completionHandler: { [weak self] result in
            guard let self = self else {
                return
            }
            
            if urls.isEmpty {
                completion()
            } else {
                self.download(imageUrls: urls, completion: completion)
            }
        })
    }
    
    func urls(from comics: Comics) -> [URL] {
        var urls = [comics.imageUrl]
        
        comics.chapters.forEach { chapter in
            chapter.content.forEach { block in
                urls.append(contentsOf: [
                    block.placeholderImageUrl,
                    block.originalImageUrl
                ])
            }
        }
        
        return urls
    }
}
