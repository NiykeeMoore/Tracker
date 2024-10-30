//
//  SetSheduleViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 08.10.2024.
//

import UIKit

class ScheduleSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var setSchedule: (([Weekdays]) -> Void)?
    var selectedDays: [Weekdays] = []
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .black, aligment: .center)
        label.text = "Расписание"
        return label
    }()
    
    private lazy var scheduleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    private lazy var setScheduleButton: UIButton = {
        let button = UIButton()
        button.applyCustomStyle(
            title: "Готово", forState: .normal, titleFont: .boldSystemFont(ofSize: 16),
            titleColor: .white, titleColorState: .normal,
            backgroundColor: .black,
            cornerRadius: 16)
        button.addTarget(self, action: #selector(saveSelectedDays), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        configureConstraints()
        configureStackView()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        [titleViewController, scheduleStackView, setScheduleButton].forEach {
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
            
            scheduleStackView.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 15),
            scheduleStackView.bottomAnchor.constraint(equalTo: setScheduleButton.topAnchor, constant: -47),
            scheduleStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scheduleStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            
            setScheduleButton.heightAnchor.constraint(equalToConstant: 60),
            setScheduleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            setScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            setScheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
    }
    
    // MARK: - Constraints
    
    private func configureStackView() {
        for day in Weekdays.allCases {
            let container = createSheduleContainer(for: day.rawValue)
            scheduleStackView.addArrangedSubview(container)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createSheduleContainer(for day: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .ccLightGray
        
        let dayLabel = UILabel()
        dayLabel.text = day
        dayLabel.font = .systemFont(ofSize: 16)
        dayLabel.textColor = .black
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let daySwitch = UISwitch()
        daySwitch.tag = Weekdays.allCases.firstIndex { $0.rawValue == day } ?? 0
        daySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = .blue
        
        container.addSubview(dayLabel)
        container.addSubview(daySwitch)
        
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            daySwitch.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func sortDaysOfWeek(_ days: [Weekdays]) -> [Weekdays] {
        let dayOrder: [String: Int] = [
            Weekdays.monday.rawValue: 0,
            Weekdays.tuesday.rawValue: 1,
            Weekdays.wednesday.rawValue: 2,
            Weekdays.thursday.rawValue: 3,
            Weekdays.friday.rawValue: 4,
            Weekdays.saturday.rawValue: 5,
            Weekdays.sunday.rawValue: 6]
        return days.sorted {
            (dayOrder[$0.rawValue] ?? 6) < (dayOrder[$1.rawValue] ?? 6)
        }
    }
    
    private func updateSetScheduleButtonState() {
        setScheduleButton.isEnabled = isButtonCanBeActive()
        setScheduleButton.backgroundColor = isButtonCanBeActive() ? .ccBlack : .ccGray
    }
    
    private func isButtonCanBeActive() -> Bool {
        return selectedDays.isEmpty ? false : true
    }
    
    // MARK: - Actions
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = Weekdays.allCases[sender.tag]
        
        if sender.isOn {
            selectedDays.append(day)
            updateSetScheduleButtonState()
        } else {
            if let index = selectedDays.firstIndex(of: day) {
                selectedDays.remove(at: index)
                updateSetScheduleButtonState()
            }
        }
    }
    
    @objc private func saveSelectedDays() {
        let sortedDays = sortDaysOfWeek(selectedDays)
        setSchedule?(sortedDays)
        dismiss(animated: true, completion: nil)
    }
}
