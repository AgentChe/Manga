//
//  OCombineData.swift
//  Manga
//
//  Created by Андрей Чернышев on 23.08.2022.
//

struct OCombineData {
    let goal: Int
    let categories: [Int]
    let pace: Int
    let time: Int
    let readingMode: String
    let pushToken: String?
    let notificationsOptions: [Int]?
}

final class OnboardingCombineData {
    private var goal: OGoalButton.Goal?
    private var categories: [OCategoriesCollectionElement]?
    private var pace: Int?
    private var time: OTimeButton.Time?
    private var readingMode: ReadingMode?
    private var pushToken: String?
    private var notificationsOptions: [ONotificationsSwitch.Notification]?
    
    func combineData() -> OCombineData? {
        guard
            let goal = goal,
            let categories = categories,
            let pace = pace,
            let time = time,
            let readingMode = readingMode
        else {
            return nil
        }

        return OCombineData(
            goal: goal.code,
            categories: categories.map { $0.id },
            pace: pace,
            time: time.code,
            readingMode: readingMode.code,
            pushToken: pushToken,
            notificationsOptions: notificationsOptions?.map { $0.code }
        )
    }
}

// MARK: OGoalViewDelegate
extension OnboardingCombineData: OGoalViewDelegate {
    func goalViewDidSelected(goal: OGoalButton.Goal) {
        self.goal = goal
    }
}

// MARK: OCategoriesViewDelegate
extension OnboardingCombineData: OCategoriesViewDelegate {
    func categoriesViewDidSelected(elements: [OCategoriesCollectionElement]) {
        self.categories = elements
    }
}

// MARK: OPaceViewDelegate
extension OnboardingCombineData: OPaceViewDelegate {
    func paceViewDidSelected(pace: Int) {
        self.pace = pace
    }
}

// MARK: OTimeViewDelegate
extension OnboardingCombineData: OTimeViewDelegate {
    func timeViewDidSelected(time: OTimeButton.Time) {
        self.time = time
    }
}

// MARK: OReadingModeViewDelegate
extension OnboardingCombineData: OReadingModeViewDelegate {
    func readingModeViewDidSelected(readingMode: ReadingMode) {
        self.readingMode = readingMode
    }
}

// MARK: ONotificationsViewDelegate
extension OnboardingCombineData: ONotificationsViewDelegate {
    func notificationsViewDidRegistered(pushToken: String?, options: [ONotificationsSwitch.Notification]) {
        self.pushToken = pushToken
        self.notificationsOptions = options
    }
}
