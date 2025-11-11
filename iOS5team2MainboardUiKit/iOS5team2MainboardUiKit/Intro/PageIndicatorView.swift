//
//  PageIndicatorView.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

final class PageIndicatorView: UIView {
    private let control = UIPageControl()
    var numberOfPages: Int { get { control.numberOfPages } set { control.numberOfPages = newValue } }
    var currentPage: Int { get { control.currentPage } set { control.currentPage = newValue } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        control.pageIndicatorTintColor = .systemGray3
        control.currentPageIndicatorTintColor = .systemBlue
        control.translatesAutoresizingMaskIntoConstraints = false
        addSubview(control)
        NSLayoutConstraint.activate([
            control.centerXAnchor.constraint(equalTo: centerXAnchor),
            control.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }
}
