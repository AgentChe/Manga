//
//  ChaptersTableView.swift
//  Manga
//
//  Created by Андрей Чернышев on 15.07.2022.
//

import UIKit

protocol ChaptersTableDelegate: AnyObject {
    func chaptersTableDidTapped(chapter: ComicsChapter)
}

final class ChaptersTableView: UITableView {
    weak var mainDelegate: ChaptersTableDelegate?
    
    private lazy var elements = [ChaptersTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Pubic
extension ChaptersTableView {
    func setup(elements: [ChaptersTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension ChaptersTableView: UITableViewDataSource {
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
        case .chapter(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ChapterTableCell.self)) as! ChapterTableCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension ChaptersTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .offset:
            return 16.scale
        case .chapter:
            return 95.scale
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .chapter(element) = elements[indexPath.row] else {
            return
        }
        
        mainDelegate?.chaptersTableDidTapped(chapter: element.chapter)
    }
}

// MARK: Private
private extension ChaptersTableView {
    func initialize() {
        register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        register(ChapterTableCell.self, forCellReuseIdentifier: String(describing: ChapterTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
