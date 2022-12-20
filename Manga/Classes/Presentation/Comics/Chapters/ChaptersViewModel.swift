//
//  ChaptersViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import RxSwift
import RxCocoa

final class ChaptersViewModel {
    let selectChapter: BehaviorRelay<ComicsChapter>
    lazy var didTapSort = PublishRelay<Void>()
    
    lazy var elements = makeElements()
    
    private let chapters: BehaviorRelay<[ComicsChapter]>
    
    private lazy var sort = makeSort()
    
    init(chapters: [ComicsChapter], selectedChapter: ComicsChapter) {
        self.chapters = BehaviorRelay(value: chapters)
        self.selectChapter = BehaviorRelay(value: selectedChapter)
    }
}

// MARK: Private
private extension ChaptersViewModel {
    func makeElements() -> Driver<[ChaptersTableElement]> {
        Driver
            .combineLatest(
                chapters.asDriver(),
                selectChapter.asDriver(),
                sort
            )
            .map { [weak self] chapters, selectedChapter, sort -> [ChaptersTableElement] in
                guard let self = self else {
                    return []
                }
                
                var result = [ChaptersTableElement]()
                
                let sortedChapters = self.sortChapters(chapters, sortBy: sort)
                
                sortedChapters.enumerated().forEach { index, sortedChapter in
                    let isLast = (sortedChapters.count - 1) == index
                    
                    let element = ChaptersTableChapterElement(chapter: sortedChapter.0,
                                                              title: sortedChapter.1,
                                                              isSelected: sortedChapter.0 == selectedChapter,
                                                              separatorHidden: isLast)
                    result.append(.chapter(element))
                    
                    if !isLast {
                        result.append(.offset)
                    }
                }
                
                return result
            }
    }
    
    func makeSort() -> Driver<Sort> {
        didTapSort
            .scan(Sort.descending) { sort, void -> Sort in
                switch sort {
                case .ascending:
                    return .descending
                case .descending:
                    return .ascending
                }
            }
            .startWith(.descending)
            .asDriver(onErrorDriveWith: .never())
    }
}

// MARK: Private (Additional)
private extension ChaptersViewModel {
    enum Sort {
        case ascending
        case descending
    }
    
    func sortChapters(_ chapters: [ComicsChapter], sortBy: Sort) -> [(ComicsChapter, String)] {
        chapters
            .sorted(by: { $0.sort < $1.sort })
            .enumerated()
            .map { index, chapter -> (Int, ComicsChapter) in
                (index + 1, chapter)
            }
            .sorted(by: { comicsLeft, comicsRight -> Bool in
                switch sortBy {
                case .ascending:
                    return comicsLeft.0 < comicsRight.0
                case .descending:
                    return comicsLeft.0 > comicsRight.0
                }
            })
            .map { index, chapter -> (ComicsChapter, String) in
                (chapter, String(format: "Chapters.ChapterNumber".localized, index))
            }
    }
}
