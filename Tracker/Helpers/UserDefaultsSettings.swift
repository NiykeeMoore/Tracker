//
//  UserDefaultsSettings.swift
//  Tracker
//
//  Created by Niykee Moore on 20.11.2024.
//

import Foundation

final class UserDefaultsSettings {
    static let shared = UserDefaultsSettings()
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case onboardingWasShown
    }

    private init() {}

    var onboardingWasShown: Bool {
        get {
            userDefaults.bool(forKey: Keys.onboardingWasShown.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.onboardingWasShown.rawValue)
        }
    }
}
