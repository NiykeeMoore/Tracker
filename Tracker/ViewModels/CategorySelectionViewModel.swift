//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by Niykee Moore on 17.11.2024.
//

import Foundation

final class CategorySelectionViewModel {
    
    var onWarningMessageChanged: ((String?) -> Void)?
    var onCreatedCategoryNameChanged: ((String?) -> Void)?
    
    var selectedCategory: String?
    var categoriesList: [String] = [] {
        didSet {
            onCategoriesListUpdated?()
        }
    }
    var onCategoriesListUpdated: (() -> Void)?
    
    var createdCategoryName: String = "" {
        didSet {
            onCreatedCategoryNameChanged?(createdCategoryName)
        }
    }
    
    private(set) var warningMessage: String? {
        didSet {
            onWarningMessageChanged?(warningMessage)
        }
    }
    
    func fetchCategories() {
        categoriesList = StoreManager.shared.categoryStore.fetchAllCategoriesName()
        onCategoriesListUpdated?()
    }
    
    func createCategory() {
        
        if categoriesList.contains(where: { $0 == createdCategoryName }) {
            print("Категория с таким названием уже существует!")
            return
        }
        
        StoreManager.shared.categoryStore.createCategory(name: createdCategoryName)
        categoriesList.append(createdCategoryName)
        onCategoriesListUpdated?()
    }
    
    func isCreateButtonEnabled() -> Bool {
        return !createdCategoryName.isEmpty
    }
    
    func updateWarningMessage(for text: String, limit: Int) {
        if text.count > limit {
            warningMessage = "Ограничение \(limit) символов"
        } else {
            warningMessage = nil
        }
    }
}
