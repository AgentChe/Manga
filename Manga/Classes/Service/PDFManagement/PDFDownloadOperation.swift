//
//  PDFDownloadOperation.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import PDFKit

final class PDFDownloadOperation: NSObject {
    deinit {
        downloadTask?.cancel()
    }
    
    let remoteUrl: URL
    let localUrl: URL
    
    private var downloadTask: URLSessionDownloadTask?
    
    private var completion: ((PDFDocument?) -> Void)?
    
    init(url: URL) {
        self.remoteUrl = url
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.localUrl = documentDirectory.appendingPathComponent(remoteUrl.lastPathComponent)
        
        super.init()
    }
}

// MARK: URLSessionDownloadDelegate
extension PDFDownloadOperation: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        try? FileManager.default.removeItem(at: localUrl)
        
        do {
            try FileManager.default.copyItem(at: location, to: localUrl)
            
            complete()
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.completion?(nil)
            }
        }
    }
}

// MARK: Public
extension PDFDownloadOperation {
    func loadPDF(completion: @escaping ((PDFDocument?) -> Void)) {
        self.completion = completion
        
        if FileManager.default.fileExists(atPath: localUrl.path) {
            complete()
        } else {
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            downloadTask = urlSession.downloadTask(with: remoteUrl)
            downloadTask?.resume()
        }
    }
}

// MARK: Private
private extension PDFDownloadOperation {
    func complete() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            
            let document = PDFDocument(url: self.localUrl)
            
            DispatchQueue.main.async {
                self.completion?(document)
            }
        }
    }
}
