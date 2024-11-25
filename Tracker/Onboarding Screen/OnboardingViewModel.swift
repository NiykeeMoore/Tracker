//
//  OnboardingViewModel.swift
//  Tracker
//
//  Created by Niykee Moore on 20.11.2024.
//

import Foundation

final class OnboardingViewModel {
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "onboardingWasShown"
    
    var shouldShowOnboarding: Bool {
        return !userDefaults.bool(forKey: onboardingKey)
    }
    
    func setOnboardingSeen() {
        userDefaults.set(true, forKey: onboardingKey)
    }
}
