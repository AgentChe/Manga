//
//  ReaderPDFCell.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import UIKit
import PDFKit

final class ReaderPDFCell: UICollectionViewCell {
    lazy var pdfView = makePDFView()
    lazy var placeholderView = makePlaceholderView()
    lazy var preloader = makePreloader()
    
    private var operation: PDFDownloadOperation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ReaderPDFCell {
    func setup(element: URL, readingMode: ReadingMode) {
        switch readingMode {
        case .vertical:
            pdfView.displaysRTL = false
            pdfView.displayDirection = .vertical
        case .rtl:
            pdfView.displaysRTL = true
            pdfView.displayDirection = .horizontal
        case .ltr:
            pdfView.displaysRTL = false
            pdfView.displayDirection = .horizontal
        }
        
        preloader.startAnimating()
        placeholderView.isHidden = true
        
        operation = PDFDownloadOperation(url: element)
        operation?.loadPDF { [weak self] document in
            self?.preloader.stopAnimating()
            self?.pdfView.document = document
            self?.placeholderView.isHidden = document != nil
        }
    }
}

// MARK: Private
private extension ReaderPDFCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension ReaderPDFCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderView.widthAnchor.constraint(equalToConstant: 85.scale),
            placeholderView.heightAnchor.constraint(equalToConstant: 80.scale),
            placeholderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReaderPDFCell {
    func makePDFView() -> PDFView {
        let view = PDFView()
        view.backgroundColor = UIColor.clear
        view.displayMode = .singlePage
        view.usePageViewController(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePlaceholderView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Reader.Placeholder")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
