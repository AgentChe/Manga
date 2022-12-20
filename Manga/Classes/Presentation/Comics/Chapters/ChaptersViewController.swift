//
//  ChaptersViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import UIKit
import RxSwift

final class ChaptersViewController: UIViewController {
    lazy var mainView = ChaptersView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let viewModel: ChaptersViewModel
    private let selected: ((ComicsChapter) -> Void)
    
    private init(chapters: [ComicsChapter], selectedChapter: ComicsChapter, selected: @escaping ((ComicsChapter) -> Void)) {
        viewModel = ChaptersViewModel(chapters: chapters, selectedChapter: selectedChapter)
        self.selected = selected
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Chapters Screen")
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.sortButton.rx.tap
            .bind(to: viewModel.didTapSort)
            .disposed(by: disposeBag)
        
        viewModel.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension ChaptersViewController {
    static func make(chapters: [ComicsChapter], selectedChapter: ComicsChapter, selected: @escaping ((ComicsChapter) -> Void)) -> ChaptersViewController {
        let vc = ChaptersViewController(chapters: chapters, selectedChapter: selectedChapter, selected: selected)
        vc.modalPresentationStyle = .popover
        return vc
    }
}

// MARK: ChaptersTableDelegate
extension ChaptersViewController: ChaptersTableDelegate {
    func chaptersTableDidTapped(chapter: ComicsChapter) {
        dismiss(animated: true) { [weak self] in
            self?.selected(chapter)
        }
    }
}
