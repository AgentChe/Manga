//
//  ReaderTableImagesView.swift
//  Manga
//
//  Created by Андрей Чернышев on 20.12.2022.
//

import UIKit

final class ReaderTableImagesView: UITableView {
    private var rowsHeight = [Int: CGFloat]()
    
    private lazy var elements = [URL]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ReaderTableImagesView {
    func setup(elements: [URL]) {
        rowsHeight = [:]
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension ReaderTableImagesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        let cell = dequeueReusableCell(withIdentifier: String(describing: ReaderTableImagesCell.self)) as! ReaderTableImagesCell
        cell.setup(imageUrl: element) { [weak self] height in
            guard let self = self, !self.rowsHeight.contains(where: { $0.key == indexPath.row }) else {
                return
            }
            
            self.rowsHeight[indexPath.row] = height
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension ReaderTableImagesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = rowsHeight[indexPath.row] {
            return height
        }
        
        return bounds.height
    }
}

// MARK: Private
private extension ReaderTableImagesView {
    func initialize() {
        register(ReaderTableImagesCell.self, forCellReuseIdentifier: String(describing: ReaderTableImagesCell.self))
        
        dataSource = self
        delegate = self
    }
}
