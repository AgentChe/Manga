//
//  ComicsStatus.swift
//  Manga
//
//  Created by Андрей Чернышев on 02.12.2022.
//

enum ComicsStatus: Codable, Hashable {
    case `none`, ongoing, completed
    
    init?(code: Int) {
        switch code {
        case 0:
            self = .none
        case 1:
            self = .ongoing
        case 2:
            self = .completed
        default:
            return nil
        }
    }
}
