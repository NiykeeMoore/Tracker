//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 20.11.2024.
//

import UIKit

final class OnboardingViewController: UIViewController {
    var onboardingDidEnd: (() -> Void)?
    
    private let viewModel = OnboardingViewModel()
    private var pageViewController: UIPageViewController!
    private let pages: [UIViewController] = [
        OnboardingPageViewController(imageName: "onboardingBlue", description: NSLocalizedString("title_first_screen", comment: "")),
        OnboardingPageViewController(imageName: "onboardingRed", description: NSLocalizedString("title_second_screen", comment: ""))
    ]
    private var currentIndex = 0
    
    private lazy var skipOnboardingButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyCustomStyle(title: NSLocalizedString("skip_button", comment: ""), forState: .normal,
                                titleFont: .systemFont(ofSize: 16), titleColor: .white, titleColorState: .normal,
                                backgroundColor: .ccBlack,
                                cornerRadius: 16)
        button.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)
        return button
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .ccBlack
        control.pageIndicatorTintColor = .ccGray
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPageViewController()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        pageControl.numberOfPages = pages.count
        
        [pageControl, skipOnboardingButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: skipOnboardingButton.bottomAnchor, constant: -60),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            skipOnboardingButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            skipOnboardingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            skipOnboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipOnboardingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipOnboardingButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: true)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.frame = view.bounds
    }
    
    @objc private func finishOnboarding() {
        viewModel.setOnboardingSeen()
        onboardingDidEnd?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = (index - 1 + pages.count) % pages.count
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = (index + 1) % pages.count
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: currentVC) {
            currentIndex = index
            pageControl.currentPage = index
        }
    }
}
