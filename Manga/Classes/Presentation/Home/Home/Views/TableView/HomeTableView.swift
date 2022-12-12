//
//  HomeTableView.swift
//  Manga
//
//  Created by Андрей Чернышев on 07.07.2022.
//

import UIKit

protocol HomeTableDelegate: AnyObject {
    func homeTableDidTapped(comics: ComicsCover)
    func homeTableDidTapped(category: Category)
    func homeTableDidTappedComicsInProgress()
    func homeTableDidTapped(ranking: Ranking)
}

final class HomeTableView: UITableView {
    weak var mainDelegate: HomeTableDelegate?
    
    private lazy var elements = [HomeTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableView {
    func setup(elements: [HomeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension HomeTableView: UITableViewDataSource {
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
        case .freeComics(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeFreeComicsCell.self)) as! HomeFreeComicsCell
            cell.setup(element: element)
            return cell
        case .comicsByCategory(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeComicsBlockCell.self)) as! HomeComicsBlockCell
            cell.setup(title: element.category.name, comics: element.comics, canOpen: element.canOpen, tapped: { [weak self] comics in
                self?.mainDelegate?.homeTableDidTapped(comics: comics.comics)
            })
            return cell
        case .comicsByRanking(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeComicsBlockCell.self)) as! HomeComicsBlockCell
            cell.setup(title: element.ranking.name, comics: element.comics, canOpen: element.canOpen, tapped: { [weak self] comics in
                self?.mainDelegate?.homeTableDidTapped(comics: comics.comics)
            })
            return cell
        case .comicsInProgress(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeComicsBlockCell.self)) as! HomeComicsBlockCell
            cell.setup(title: element.title, comics: element.comics, canOpen: true, tapped: { [weak self] comics in
                self?.mainDelegate?.homeTableDidTapped(comics: comics.comics)
            })
            return cell
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTitleCell.self)) as! HomeTitleCell
            cell.setup(title: element)
            return cell
        case .comicsNumber(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeComicsNumberCell.self)) as! HomeComicsNumberCell
            cell.setup(element: element)
            return cell
        case .separator:
            return dequeueReusableCell(withIdentifier: String(describing: HomeSeparatorCell.self))!
        case .categories(let elements):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeCategoriesCell.self)) as! HomeCategoriesCell
            cell.setup(elements: elements, tapped: { [weak self] category in
                self?.mainDelegate?.homeTableDidTapped(category: category)
            })
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension HomeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .offset(let offset):
            return offset
        case .freeComics:
            return 309.scale
        case .comicsByCategory, .comicsByRanking, .comicsInProgress:
            return 323.scale
        case .title:
            return 24.scale
        case .comicsNumber:
            return 78.scale
        case .separator:
            return 1.scale
        case .categories:
            return 45.scale
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .freeComics(let element):
            mainDelegate?.homeTableDidTapped(comics: element.comics)
        case .comicsByCategory(let element):
            if element.canOpen {
                mainDelegate?.homeTableDidTapped(category: element.category)
            }
        case .comicsByRanking(let element):
            if element.canOpen {
                mainDelegate?.homeTableDidTapped(ranking: element.ranking)
            }
        case .comicsInProgress:
            mainDelegate?.homeTableDidTappedComicsInProgress()
        case .comicsNumber(let element):
            mainDelegate?.homeTableDidTapped(comics: element.comics.comics)
        default:
            break
        }
    }
}

// MARK: Private
private extension HomeTableView {
    func initialize() {
        register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        register(HomeFreeComicsCell.self, forCellReuseIdentifier: String(describing: HomeFreeComicsCell.self))
        register(HomeComicsBlockCell.self, forCellReuseIdentifier: String(describing: HomeComicsBlockCell.self))
        register(HomeTitleCell.self, forCellReuseIdentifier: String(describing: HomeTitleCell.self))
        register(HomeComicsNumberCell.self, forCellReuseIdentifier: String(describing: HomeComicsNumberCell.self))
        register(HomeSeparatorCell.self, forCellReuseIdentifier: String(describing: HomeSeparatorCell.self))
        register(HomeCategoriesCell.self, forCellReuseIdentifier: String(describing: HomeCategoriesCell.self))
        
        dataSource = self
        delegate = self
    }
}
