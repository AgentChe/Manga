//
//  DownloadComicsQueue.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.12.2022.
//

final class DownloadComicsQueue {
    static let shared = DownloadComicsQueue()
    
    private init() {}
    
    private var operations = [Int: DownloadComicsOperation]()
}

// MARK: Public
extension DownloadComicsQueue {
    func download(comics: Comics, completion: @escaping (() -> Void)) {
        let key = comics.id
        
        let operation = DownloadComicsOperation(comics: comics) { [weak self] in
            self?.operations.removeValue(forKey: key)
            
            completion()
        }
        operations[key] = operation
    }
    
    func removeOperation(for comicsId: Int) {
        operations.removeValue(forKey: comicsId)
    }
    
    func containsOperation(with comicsId: Int) -> Bool {
        operations.contains(where: { $0.key == comicsId })
    }
}
