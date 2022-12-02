//
//  SplashSDKInitialize.swift
//  BookSummaries
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import RxSwift
import RxCocoa
import UIKit

final class SplashSDKInitialize {
    enum Progress {
        case error, initializing, complete
    }
    
    private lazy var validationObserver = SplashReceiptValidationObserver()
}

// MARK: Public
extension SplashSDKInitialize {
    func initialize(handler: @escaping ((Progress) -> Void)) {
        handler(.initializing)
        
        validationObserver.observe {
            handler(.complete)
        }
    }
}
