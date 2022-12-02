//
//  Fonts.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import UIKit

struct Fonts {
    // MARK: PlusJakartaSans
    struct PlusJakartaSans {
        static func extraBold(size: CGFloat) -> UIFont {
            UIFont(name: "PlusJakartaSans-ExtraBold", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "PlusJakartaSans-Bold", size: size)!
        }
        
        static func medium(size: CGFloat) -> UIFont {
            UIFont(name: "PlusJakartaSans-Medium", size: size)!
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            UIFont(name: "PlusJakartaSans-SemiBold", size: size)!
        }
        
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "PlusJakartaSans-Regular", size: size)!
        }
    }
}
