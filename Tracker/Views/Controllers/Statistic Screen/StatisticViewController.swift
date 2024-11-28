//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 26.09.2024.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: TaskListViewModel
    private let trackerRecordStore = StoreManager.shared.recordStore
    private let trackerStore = StoreManager.shared.trackerStore
    private var statistics: [Statistic] = []
    
    private lazy var placeholderImage: UIImageView = {
        let image = UIImage(named: "placeholderStatisticList")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.configureLabel(font: .boldSystemFont(ofSize: 12), textColor: .ccBlack, aligment: .center)
        return label
    }()
    
    private lazy var statiscticsCardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        for statistic in statistics {
            let view = createViewForStackView(with: statistic)
            stackView.addArrangedSubview(view)
        }
        
        return stackView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        loadStatistics()
        placeholderIfNeeded()
        
        viewModel.onCompletedDaysCountUpdated = { [weak self] in
            self?.reloadStatisticsStack()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        statiscticsCardsStackView.isLayoutMarginsRelativeArrangement = true
        statiscticsCardsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        [placeholderImage, placeholderLabel, statiscticsCardsStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func createViewForStackView(with statistic: Statistic) -> UIView {
        let containerView = GradientBorderView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        let counterLabel = UILabel()
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.text = "\(statistic.value)"
        counterLabel.font = .boldSystemFont(ofSize: 34)
        counterLabel.textColor = .ccBlack
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = statistic.title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .ccBlack
        
        containerView.addSubview(counterLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            counterLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            counterLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -7),
            
            titleLabel.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18),
            
            statiscticsCardsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            statiscticsCardsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            statiscticsCardsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Private functions
    
    private func placeholderIfNeeded() {
        let hasData = !statistics.isEmpty
        placeholderImage.isHidden = hasData
        placeholderLabel.isHidden = hasData
        statiscticsCardsStackView.isHidden = !hasData
    }
    
    private func loadStatistics() {
        guard let allTrackers = trackerStore.fetchAllTrackers() else { return }
        let allRecords = trackerRecordStore.fetchAllRecords()
        calculateStatistics(records: allRecords, trackers: allTrackers)
    }
    
    private func calculateStatistics(records: [TrackerRecord], trackers: [Tracker]) {
        guard !records.isEmpty else {
            statistics = []
            return
        }
        
        let totalCompleted = records.count
        let bestPeriod = calculateBestPeriod(records: records)
        let perfectDays = calculatePerfectDays(records: records, allTrackers: trackers)
        let averageCompletion = calculateAverage(records: records)
        
        statistics = [
            Statistic(value: "\(bestPeriod)", title: "Лучший период"),
            Statistic(value: "\(perfectDays)", title: "Идеальные дни"),
            Statistic(value: "\(totalCompleted)", title: "Трекеров завершено"),
            Statistic(value: "\(averageCompletion)", title: "Среднее значение"),
        ]
        
        DispatchQueue.main.async {
            self.reloadStatisticsStack()
        }
    }
    
    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let sortedDates = records.map { $0.dueDate }.sorted()
        var longestStreak = 0
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let prevDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if Calendar.current.isDate(currentDate, inSameDayAs: prevDate.addingTimeInterval(86400)) {
                currentStreak += 1
            } else {
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 1
            }
        }
        return max(longestStreak, currentStreak)
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], allTrackers: [Tracker]) -> Int {
        guard !records.isEmpty, !allTrackers.isEmpty else { return 0 }
        
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.dueDate) })
        var perfectDays = 0
        
        for (_, dailyRecords) in groupedByDay {
            let uniqueTrackers = Set(dailyRecords.map { $0.id })
            if uniqueTrackers.count == allTrackers.count {
                perfectDays += 1
            }
        }
        return perfectDays
    }
    
    private func calculateAverage(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.dueDate) })
        let daysCount = groupedByDay.count
        
        return records.count / daysCount
    }
    
    private func reloadStatisticsStack() {
        statiscticsCardsStackView.arrangedSubviews.forEach { view in
            statiscticsCardsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for statistic in statistics {
            let view = createViewForStackView(with: statistic)
            statiscticsCardsStackView.addArrangedSubview(view)
        }
    }
}
