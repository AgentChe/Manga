//
//  ProfileMediator.swift
//  Manga
//
//  Created by Андрей Чернышев on 28.03.2023.
//

import RxSwift
import RxCocoa

final class ProfileMediator {
    static let shared = ProfileMediator()
    
    private lazy var didChangeGoalTrigger = PublishRelay<Int>()
    private lazy var didChangeCategoriesTrigger = PublishRelay<[Int]>()
    private lazy var didChangePaceTrigger = PublishRelay<Int>()
    private lazy var didChangeTimeTrigger = PublishRelay<Int>()
    private lazy var didChangeNotificationsOptionsTrigger = PublishRelay<[Int]>()
    private lazy var didChangeReadingModeTrigger = PublishRelay<ReadingMode>()
    
    private init() {}
}

// MARK: Public
extension ProfileMediator {
    func didChange(goal: Int) {
        DispatchQueue.main.async {
            Self.shared.didChangeGoalTrigger.accept(goal)
        }
    }
    
    func didChange(categories: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didChangeCategoriesTrigger.accept(categories)
        }
    }
    
    func didChange(pace: Int) {
        DispatchQueue.main.async {
            Self.shared.didChangePaceTrigger.accept(pace)
        }
    }
    
    func didChange(time: Int) {
        DispatchQueue.main.async {
            Self.shared.didChangeTimeTrigger.accept(time)
        }
    }
    
    func didChange(notificationsOptions: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didChangeNotificationsOptionsTrigger.accept(notificationsOptions)
        }
    }
    
    func didChange(readingMode: ReadingMode) {
        DispatchQueue.main.async {
            Self.shared.didChangeReadingModeTrigger.accept(readingMode)
        }
    }
    
    var didChangeGoal: Signal<Int> {
        didChangeGoalTrigger.asSignal()
    }
    
    var didChangeCategories: Signal<[Int]> {
        didChangeCategoriesTrigger.asSignal()
    }
    
    var didChangePace: Signal<Int> {
        didChangePaceTrigger.asSignal()
    }
    
    var didChangeTime: Signal<Int> {
        didChangeTimeTrigger.asSignal()
    }
    
    var didChangeNotificationsOptions: Signal<[Int]> {
        didChangeNotificationsOptionsTrigger.asSignal()
    }
    
    var didChangeReadingMode: Signal<ReadingMode> {
        didChangeReadingModeTrigger.asSignal()
    }
}
