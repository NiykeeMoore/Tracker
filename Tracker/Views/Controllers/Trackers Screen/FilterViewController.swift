//
//  FilterViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 28.11.2024.
//

import UIKit

final class FilterViewController: UIViewController,
                                  UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    
    var onFilterSelected: (() -> Void)?
    
    private let viewModel: TaskListViewModel
    private let rowHeight: CGFloat = 75
    private let numberOfRows = Filters.allCases.count - 1
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        label.text = "Фильтры"
        return label
    }()
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .clear
        tableView.register(CategorySelectionCell.self, forCellReuseIdentifier: CategorySelectionCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ccWhite
        configureUI()
        configureConstraints()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        [titleViewController, filtersTableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleViewController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleViewController.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            
            filtersTableView.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: CGFloat(numberOfRows) * rowHeight)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectionCell.reuseIdentifier,
                                                       for: indexPath) as? CategorySelectionCell else {
            return UITableViewCell()
        }
        
        cell.renderCell(with: Filters.allCases[indexPath.row].rawValue)
        
        if viewModel.selectedFilter == Filters.allCases[indexPath.row] {
            cell.makeSelected()
        }
        
        cell.showOrHideSeparator(isHidden: indexPath.row == numberOfRows - 1)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        for cell in tableView.visibleCells {
            if let allCells = cell as? CategorySelectionCell {
                allCells.resetSelection()
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell {
            cell.makeSelected()
            viewModel.selectedFilter = Filters.allCases[indexPath.row]
            onFilterSelected?()
        }
    }
}
