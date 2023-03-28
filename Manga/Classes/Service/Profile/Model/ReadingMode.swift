//
//  ReadingMode.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

enum ReadingMode: Codable, Hashable {
    case vertical
    case rtl
    case ltr
}

// MARK: Public
extension ReadingMode {
    init?(code: String) {
        switch code {
        case "vertical":
            self = .vertical
        case "rtl":
            self = .rtl
        case "ltr":
            self = .ltr
        default:
            return nil
        }
    }
    
    var code: String {
        switch self {
        case .vertical:
            return "vertical"
        case .rtl:
            return "rtl"
        case .ltr:
            return "ltr"
        }
    }
}
