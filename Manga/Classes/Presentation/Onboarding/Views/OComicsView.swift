//
//  OComicsView.swift
//  Manga
//
//  Created by Андрей Чернышев on 24.08.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class OComicsView: OSlideView {
    weak var vc: UIViewController?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var imagesCollectionView = makeImagesCollectionView()
    lazy var nameLabel = makeLabel()
    lazy var dislikeButton = makeDislikeButton()
    lazy var likeButton = makeLikeButton()
    lazy var preloader = makePreloader()
    
    private lazy var selectedCategoriesIds = PublishRelay<[Int]>()
    private lazy var likedComics = PublishRelay<[ComicsCover]>()
    
    private lazy var comics = makeComics()
    private lazy var liked = makeLiked()
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var contentManager = ContentManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private lazy var disposeBag = DisposeBag()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initalize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func moveToThis() {
        super.moveToThis()
        
        AmplitudeManager.shared
            .logEvent(name: "Personalisation Screen")
    }
}

// MARK: OCategoriesViewDelegate
extension OComicsView: OCategoriesViewDelegate {
    func categoriesViewDidSelected(elements: [OCategoriesCollectionElement]) {
        let ids = elements.map { $0.id }
        selectedCategoriesIds.accept(ids)
    }
}

// MARK: OComicsImageCollectionViewDelegate
extension OComicsView: OComicsImageCollectionViewDelegate {
    func comicsImageCollectionDidChange(frontComics: ComicsCover) {
        let nameAttrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.bold(size: 20.scale))
            .lineHeight(24.scale)
            .letterSpacing(-0.17.scale)
            .textAlignment(.center)
        nameLabel.attributedText = frontComics.name.attributed(with: nameAttrs)
    }
}

// MARK: Private
private extension OComicsView {
    func initalize() {
        backgroundColor = UIColor(integralRed: 33, green: 33, blue: 33)
        
        activity
            .drive(Binder(self) { base, activity in
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
                
                let hiddenViews = [
                    base.imagesCollectionView,
                    base.dislikeButton,
                    base.likeButton,
                    base.nameLabel
                ]
                hiddenViews.forEach { $0.isHidden = activity }
            })
            .disposed(by: disposeBag)
        
        comics
            .drive(Binder(self) { base, comics in
                base.imagesCollectionView.setup(comics: comics) { likedComics in
                    base.likedComics.accept(likedComics)
                }
            })
            .disposed(by: disposeBag)
        
        liked
            .drive(Binder(self) { base, void in
                base.onNext()
            })
            .disposed(by: disposeBag)
    }
    
    func makeComics() -> Driver<[ComicsCover]> {
        selectedCategoriesIds
            .flatMapLatest { [weak self] ids -> Observable<[ComicsCover]> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<[ComicsCover]> {
                    let zipped = ids.map { id -> Single<[ComicsCover]> in
                        self.contentManager
                            .obtainCategoryComicsCover(categoryId: id)
                    }
                    return Single
                        .zip(zipped)
                        .map { comics -> [ComicsCover] in
                            comics.reduce([]) { $0 + $1 }
                        }
                }
                
                func error(err: Error) -> Observable<Void> {
                    self.openError()
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { error(err: $0) })
                    .trackActivity(self.activity)
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeLiked() -> Driver<Void> {
        likedComics
            .flatMapLatest { [weak self] comics -> Observable<Void> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    let zipped = comics.map { comics -> Single<Bool> in
                        self.contentManager
                            .save(comics: comics)
                    }
                    return Single
                        .zip(zipped)
                        .flatMap { results -> Single<Void> in
                            if results.contains(false) {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(Void())
                        }
                }
                
                func error(err: Error) -> Observable<Void> {
                    self.openError()
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { error(err: $0) })
                    .trackActivity(self.activity)
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self.vc?.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    @objc
    func likeTapped() {
        imagesCollectionView.like()
    }
    
    @objc
    func dislikeTapped() {
        imagesCollectionView.dislike()
    }
}

// MARK: Make constraints
private extension OComicsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 126.scale : 42.scale)
        ])
        
        NSLayoutConstraint.activate([
            imagesCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imagesCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 74.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 45.scale),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -45.scale),
            nameLabel.topAnchor.constraint(equalTo: imagesCollectionView.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            dislikeButton.widthAnchor.constraint(equalToConstant: 147.scale),
            dislikeButton.heightAnchor.constraint(equalToConstant: 100.scale),
            dislikeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35.scale),
            dislikeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -83.scale : -23.scale)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 147.scale),
            likeButton.heightAnchor.constraint(equalToConstant: 100.scale),
            likeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 194.scale),
            likeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -83.scale : -23.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: imagesCollectionView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OComicsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.PlusJakartaSans.bold(size: 28.scale))
            .lineHeight(36.4.scale)
            .letterSpacing(-0.37.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.Comics.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImagesCollectionView() -> OComicsImageCollectionView {
        let view = OComicsImageCollectionView()
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDislikeButton() -> OComicsButton {
        let view = OComicsButton(primaryImage: "Onboarding.Comics.Normal.Dislike",
                                 highlitedImage: "Onboarding.Comics.Select.Dislike")
        view.backgroundColor = Appearance.black
        view.layer.cornerRadius = 20.scale
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6.scale
        view.isHighlighted = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(dislikeTapped), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeLikeButton() -> OComicsButton {
        let view = OComicsButton(primaryImage: "Onboarding.Comics.Normal.Like",
                                 highlitedImage: "Onboarding.Comics.Select.Like")
        view.backgroundColor = Appearance.black
        view.layer.cornerRadius = 20.scale
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6.scale
        view.isHighlighted = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
