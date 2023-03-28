//
//  SettingsViewController.swift
//  Manga
//
//  Created by Андрей Чернышев on 09.07.2022.
//

import UIKit
import RxSwift

final class SettingsViewController: UIViewController {
    lazy var mainView = SettingsView()
    
    private lazy var viewModel = SettingsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Settings Screen")
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.openError()
        }
        
        viewModel.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.mainDelegate = self
    }
}

// MARK: Make
extension SettingsViewController {
    static func make() -> SettingsViewController {
        let vc = SettingsViewController()
        vc.navigationItem.title = "Settings.Title".localized
        return vc
    }
}

// MARK: SettingsTableDelegate
extension SettingsViewController: SettingsTableDelegate {
    func settingsTableDidTappedContactUs() {
        AmplitudeManager.shared
            .logEvent(name: "Settings Tap", parameters: ["what": "contact us"])
        
        guard let url = URL(string: GlobalDefinitions.contactUsUrl) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:])
    }
    
    func settingsTableDidTappedPrivacyPolicy() {
        AmplitudeManager.shared
            .logEvent(name: "Settings Tap", parameters: ["what": "privacy policy"])
        
        guard let url = URL(string: GlobalDefinitions.privacyPolicyUrl) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:])
    }
    
    func settingsTableDidTappedTermsOfUse() {
        AmplitudeManager.shared
            .logEvent(name: "Settings Tap", parameters: ["what": "terms of use"])
        
        guard let url = URL(string: GlobalDefinitions.termsOfServiceUrl) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:])
    }
    
    func settingsTableDidTappedGetAccess() {
        let vc = PaygateViewController.make()
        present(vc, animated: true)
    }
    
    func settingsTableDidSelect(readingMode: ReadingMode) {
        viewModel.didSelectReadingMode.accept(readingMode)
    }
}

// MARK: Private
private extension SettingsViewController {
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
