//
//  SetSheduleViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 08.10.2024.
//

import UIKit

final class ScheduleSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var setSchedule: (([Weekdays]) -> Void)?
    private let viewModel: CreateTaskViewModel
    private let rowHeight: CGFloat = 75
    private let numberOfRows: Int = Weekdays.allCases.count
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        label.text = "Расписание"
        return label
    }()
    
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ccGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(ScheduleSelectionCell.self, forCellReuseIdentifier: ScheduleSelectionCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var setScheduleButton: UIButton = {
        let button = UIButton()
        button.applyCustomStyle(
            title: "Готово", forState: .normal, titleFont: .boldSystemFont(ofSize: 16),
            titleColor: .ccWhite, titleColorState: .normal,
            backgroundColor: .ccBlack,
            cornerRadius: 16)
        button.addTarget(self, action: #selector(saveSelectedDays), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    init(viewModel: CreateTaskViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ccWhite
        configureUI()
        configureConstraints()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        [titleViewController, scheduleTableView, setScheduleButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        updateSetScheduleButtonState()
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleViewController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleViewController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            titleViewController.heightAnchor.constraint(equalToConstant: 22),
            
            scheduleTableView.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 39),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            setScheduleButton.heightAnchor.constraint(equalToConstant: 60),
            setScheduleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            setScheduleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            setScheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            scheduleTableView.bottomAnchor.constraint(lessThanOrEqualTo: setScheduleButton.topAnchor, constant: -24)
        ])
        
        let contentHeightConstraint = scheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(numberOfRows) * rowHeight)
        contentHeightConstraint.priority = UILayoutPriority(999)
        contentHeightConstraint.isActive = true
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleSelectionCell.reuseIdentifier,
                                                       for: indexPath) as? ScheduleSelectionCell else {
            return UITableViewCell()
        }
        
        cell.renderCell(with: Weekdays.allCases[indexPath.row].rawValue, tag: indexPath.row)
        
        if indexPath.row == numberOfRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        cell.didChangeSwitchState = { [weak self] (isOn, dayIndex) in
            guard let self else { return }
            self.viewModel.updateSelectedSchedule(switchState: isOn, day: dayIndex)
            self.updateSetScheduleButtonState()
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Private Helper Methods
    
    private func updateSetScheduleButtonState() {
        setScheduleButton.isEnabled = isButtonCanBeActive()
        setScheduleButton.backgroundColor = isButtonCanBeActive() ? .ccBlack : .ccGray
    }
    
    private func isButtonCanBeActive() -> Bool {
        return viewModel.selectedDaysInSchedule.isEmpty ? false : true
    }
    
    // MARK: - Actions
    
    @objc private func saveSelectedDays() {
        setSchedule?(viewModel.selectedDaysInSchedule)
        dismiss(animated: true, completion: nil)
    }
}
