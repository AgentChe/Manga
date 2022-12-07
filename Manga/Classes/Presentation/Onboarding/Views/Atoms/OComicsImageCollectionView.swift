//
//  OComicsImageCollectionView.swift
//  Manga
//
//  Created by Андрей Чернышев on 25.08.2022.
//

import UIKit
import Kingfisher

protocol OComicsImageCollectionViewDelegate: AnyObject {
    func comicsImageCollectionDidChange(frontComics: ComicsCover)
}

final class OComicsImageCollectionView: UIView {
    weak var delegate: OComicsImageCollectionViewDelegate?
    
    private lazy var frontRect = CGRect(origin: CGPoint.zero,
                                        size: CGSize(width: 241.scale, height: 249.scale))
    private lazy var middleRect = CGRect(origin: CGPoint(x: 15.scale, y: -16.scale.scale),
                                         size: CGSize(width: 211.scale, height: 218.scale))
    private lazy var backRect = CGRect(origin: CGPoint(x: 30.scale, y: -32.scale),
                                       size: CGSize(width: 181.scale, height: 187.scale))
    
    private lazy var waitingToBeDisplayedComics = [ComicsCover]()
    private lazy var likedComics = [ComicsCover]()
    
    private lazy var imageViews = [ComicsCover: UIImageView]()
    
    private var frontComics: ComicsCover?
    private var middleComics: ComicsCover?
    private var backComics: ComicsCover?
    
    private var completion: (([ComicsCover]) -> Void)?
    
    override var intrinsicContentSize: CGSize {
        frontRect.size
    }
}

// MARK: Public
extension OComicsImageCollectionView {
    func setup(comics: [ComicsCover], completion: @escaping ([ComicsCover]) -> Void) {
        self.completion = completion
        
        initialize(comics: comics)
        createFirstViews()
        notifyAboutChangeFront()
    }
    
    func like() {
        markAsLiked()
        proceed(orientation: .right)
    }
    
    func dislike() {
        proceed(orientation: .left)
    }
}

// MARK: Private
private extension OComicsImageCollectionView {
    enum Orientation {
        case left, right
    }
    
    func markAsLiked() {
        guard let frontComics = frontComics else {
            return
        }
        
        likedComics.append(frontComics)
    }
    
    func notifyAboutChangeFront() {
        guard let frontComics = frontComics else {
            return
        }
        
        delegate?.comicsImageCollectionDidChange(frontComics: frontComics)
    }
    
    func proceed(orientation: Orientation) {
        removeFront(orientation: orientation) { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.isCompleted() {
                self.completion?(self.likedComics)
                return
            }
            
            self.upComicsLevel()
            self.updateViews()
            self.notifyAboutChangeFront()
        }
    }
    
    func removeFront(orientation: Orientation, completion: @escaping () -> Void) {
        guard let frontComics = frontComics, let frontView = imageViews[frontComics] else {
            return
        }
        
        var translationX = ((UIScreen.main.bounds.width - intrinsicContentSize.width) / 2) + intrinsicContentSize.width
        let translationY = intrinsicContentSize.height / 5
        var rotationAngle = 45 * CGFloat.pi / 180
        
        switch orientation {
        case .left:
            translationX = translationX * -1
            rotationAngle = rotationAngle * -1
        case .right:
            translationX = translationX * 1
            rotationAngle = rotationAngle * 1
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            frontView.frame.origin = CGPoint(x: translationX, y: translationY)
            frontView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            frontView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }, completion: { [weak self] result in
            frontView.removeFromSuperview()
            self?.imageViews.removeValue(forKey: frontComics)
            self?.frontComics = nil
            
            completion()
        })
    }
    
    func isCompleted() -> Bool {
        // Если middleComics nil, это значит, что был оценен последний frontComics и больше книг на оценку нет
        guard middleComics != nil else {
            return true
        }
        
        return likedComics.count == 3
    }
    
    func upComicsLevel() {
        frontComics = middleComics
        middleComics = backComics
        backComics = waitingToBeDisplayedComics.isEmpty ? nil : waitingToBeDisplayedComics.removeFirst()
    }
    
    func updateViews() {
        var frontView: UIImageView?
        var middleView: UIImageView?
        
        if let frontComics = frontComics {
            frontView = imageViews[frontComics]
        }
        
        if let middleComics = middleComics {
            middleView = imageViews[middleComics]
        }
        
        if let backComics = backComics {
            let view = makeImageView(comics: backComics)
            view.frame = backRect
            sendSubviewToBack(view)
        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            frontView?.frame = self.frontRect
            middleView?.frame = self.middleRect
        })
    }
    
    func initialize(comics: [ComicsCover]) {
        let limit = Array(comics.shuffled().prefix(6))
        
        let display = Array(limit.prefix(3))
        
        frontComics = display[safe: 0]
        middleComics = display[safe: 1]
        backComics = display[safe: 2]
        
        if limit.indices.contains(3) {
            waitingToBeDisplayedComics = Array(limit.suffix(from: 3))
        }
    }
    
    func createFirstViews() {
        imageViews.forEach { $0.value.removeFromSuperview() }
        imageViews = [:]
        
        if let backComics = backComics {
            makeImageView(comics: backComics).frame = backRect
        }
        
        if let middleComics = middleComics {
            makeImageView(comics: middleComics).frame = middleRect
        }
        
        if let frontComics = frontComics {
            makeImageView(comics: frontComics).frame = frontRect
        }
    }
    
    func makeImageView(comics: ComicsCover) -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.kf.setImage(with: comics.imageUrl)
        addSubview(view)
        imageViews[comics] = view
        return view
    }
}
