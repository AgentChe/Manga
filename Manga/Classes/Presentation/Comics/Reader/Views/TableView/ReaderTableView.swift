//
//  ReaderTableView.swift
//  Manga
//
//  Created by Андрей Чернышев on 20.12.2022.
//

import UIKit

final class ReaderTableView: UITableView {
    private lazy var elements = [ComicsChapterContentBlock]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ReaderTableView {
    func setup(elements: [ComicsChapterContentBlock]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension ReaderTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        let cell = dequeueReusableCell(withIdentifier: String(describing: ReaderTableCell.self)) as! ReaderTableCell
        cell.setup(placeholderUrl: element.placeholderImageUrl,
                   imageUrl: element.originalImageUrl)
        return cell
    }
}

// MARK: UITableViewDelegate
extension ReaderTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        elements[indexPath.row].imageHeight
    }
}

// MARK: Private
private extension ReaderTableView {
    func initialize() {
        register(ReaderTableCell.self, forCellReuseIdentifier: String(describing: ReaderTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
