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
        case pinnedTrackers
        case selectedFilter
    }
    
    private(set) var pinnedTrackers: Set<UUID> = []
    
    private init() {}
    
    var onboardingWasShown: Bool {
        get {
            userDefaults.bool(forKey: Keys.onboardingWasShown.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.onboardingWasShown.rawValue)
        }
    }
    
    func loadPinnedTrackers() {
        if let savedData = userDefaults.data(forKey: Keys.pinnedTrackers.rawValue),
           let savedIDs = try? JSONDecoder().decode(Set<UUID>.self, from: savedData) {
            pinnedTrackers = savedIDs
        } else {
            pinnedTrackers = []
        }
    }
    
    func addPinnedTracker(id: UUID) {
        pinnedTrackers.insert(id)
        savePinnedTrackers()
    }
    
    func removePinnedTracker(id: UUID) {
        pinnedTrackers.remove(id)
        savePinnedTrackers()
    }
    
    private func savePinnedTrackers() {
        if let data = try? JSONEncoder().encode(pinnedTrackers) {
            userDefaults.set(data, forKey: Keys.pinnedTrackers.rawValue)
        }
    }
    
    func isPinned(trackerId: UUID) -> Bool {
        return pinnedTrackers.contains(trackerId)
    }
    
    var selectedFilter: Int {
        get {
            return userDefaults.integer(forKey: Keys.selectedFilter.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedFilter.rawValue)
        }
    }
}
