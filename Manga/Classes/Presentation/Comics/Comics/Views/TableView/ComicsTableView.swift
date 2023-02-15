//
//  ComicsTableView.swift
//  Manga
//
//  Created by Андрей Чернышев on 11.07.2022.
//

import UIKit

protocol ComicsTableDelegate: AnyObject {
    func comicsTableDidTapped(chapter: ComicsChapter)
    func comicsTableDidTappedSeeAll()
    func comicsTableDidTapped(comics: ComicsCover)
    func comicsTableDidTapped(category: Category)
    func comicsTableDidTappedSort()
}

final class ComicsTableView: UITableView {
    weak var mainDelegate: ComicsTableDelegate?
    
    private lazy var elements = [ComicsTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Pubic
extension ComicsTableView {
    func setup(elements: [ComicsTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension ComicsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .offset:
            let cell = dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))!
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        case .cover(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsCoverCell.self)) as! ComicsCoverCell
            cell.setup(element: element)
            return cell
        case .progress(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsProgressCell.self)) as! ComicsProgressCell
            cell.setup(element: element)
            return cell
        case .info(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsInfoCell.self)) as! ComicsInfoCell
            cell.setup(element: element)
            return cell
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsTitleCell.self)) as! ComicsTitleCell
            cell.setup(element: element)
            return cell
        case .whatAbout(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsWhatAboutCell.self)) as! ComicsWhatAboutCell
            cell.setup(element: element)
            return cell
        case .chaptersTitle:
            return dequeueReusableCell(withIdentifier: String(describing: CoversChaptersTitleCell.self))!
        case .chapter(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsChapterCell.self)) as! ComicsChapterCell
            cell.setup(element: element)
            return cell
        case .separator:
            return dequeueReusableCell(withIdentifier: String(describing: ComicsSeparatorCell.self))!
        case .seeAll:
            return dequeueReusableCell(withIdentifier: String(describing: ComicsSeeAllCell.self))!
        case .creator(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ComicsCreatorCell.self)) as! ComicsCreatorCell
            cell.setup(element: element)
            return cell
        case .block(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeComicsBlockCell.self)) as! HomeComicsBlockCell
            cell.setup(title: element.ranking.name,
                       comics: element.comics,
                       canOpen: false) { [weak self] comics in
                self?.mainDelegate?.comicsTableDidTapped(comics: comics.comics)
            }
            return cell
        case .exploreCategories(let elements):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeCategoriesCell.self)) as! HomeCategoriesCell
            cell.setup(elements: elements, tapped: { [weak self] category in
                self?.mainDelegate?.comicsTableDidTapped(category: category)
            })
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension ComicsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .offset(let offset):
            return offset
        case .cover:
            return 267.scale
        case .progress:
            return 8.scale
        case .chapter:
            return 60.scale
        case .separator:
            return 1.scale
        case .seeAll:
            return 53.scale
        case .block:
            return 323.scale
        case .exploreCategories(let elements):
            guard let category = elements.first else {
                return 0
            }
            
            return HomeCategoriesCollectionCell.size(for: category).height * 2 + 16.scale
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .chapter(let element):
            mainDelegate?.comicsTableDidTapped(chapter: element.chapter)
        case .seeAll:
            mainDelegate?.comicsTableDidTappedSeeAll()
        case .chaptersTitle:
            mainDelegate?.comicsTableDidTappedSort()
        default:
            break
        }
    }
}

// MARK: Private
private extension ComicsTableView {
    func initialize() {
        register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        register(ComicsCoverCell.self, forCellReuseIdentifier: String(describing: ComicsCoverCell.self))
        register(ComicsProgressCell.self, forCellReuseIdentifier: String(describing: ComicsProgressCell.self))
        register(ComicsInfoCell.self, forCellReuseIdentifier: String(describing: ComicsInfoCell.self))
        register(ComicsTitleCell.self, forCellReuseIdentifier: String(describing: ComicsTitleCell.self))
        register(ComicsWhatAboutCell.self, forCellReuseIdentifier: String(describing: ComicsWhatAboutCell.self))
        register(CoversChaptersTitleCell.self, forCellReuseIdentifier: String(describing: CoversChaptersTitleCell.self))
        register(ComicsChapterCell.self, forCellReuseIdentifier: String(describing: ComicsChapterCell.self))
        register(ComicsSeparatorCell.self, forCellReuseIdentifier: String(describing: ComicsSeparatorCell.self))
        register(ComicsSeeAllCell.self, forCellReuseIdentifier: String(describing: ComicsSeeAllCell.self))
        register(ComicsCreatorCell.self, forCellReuseIdentifier: String(describing: ComicsCreatorCell.self))
        register(HomeComicsBlockCell.self, forCellReuseIdentifier: String(describing: HomeComicsBlockCell.self))
        register(HomeCategoriesCell.self, forCellReuseIdentifier: String(describing: HomeCategoriesCell.self))
        
        dataSource = self
        delegate = self
    }
}
