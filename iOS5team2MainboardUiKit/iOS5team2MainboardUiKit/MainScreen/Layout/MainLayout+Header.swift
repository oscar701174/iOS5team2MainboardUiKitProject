//
//  MainLayout+Header.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import DropDown

extension MainLayout {

    func setHeader() {
        addSubview(languageButton)
        addSubview(searchButton)

        languageButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        headerDefaultConstriants = [
            languageButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            languageButton.widthAnchor.constraint(equalTo: widthAnchor, constant: 30),
            searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 62),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]

        headerIPadLandscapeConstriants = [
            languageButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            languageButton.widthAnchor.constraint(
                equalTo: safeAreaLayoutGuide.widthAnchor,
                multiplier: 0.6
            ),
            languageButton.heightAnchor.constraint(equalToConstant: 90),
            searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 45),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]

        languageButton.setTitle("Swift", for: .normal)

        languageButton.setImage(UIImage(named: "SwiftLogo")?.resized(to: .init(width: 34, height: 34)), for: .normal)

        languageButton.contentHorizontalAlignment = .leading
        languageButton.titleEdgeInsets.left = 5
        languageButton.titleLabel?.lineBreakMode = .byTruncatingTail
        languageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        languageButton.setTitleColor(.main, for: .normal)
        languageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)

        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        searchButton.setImage(img, for: .normal)
        searchButton.tintColor = .main
        languageButton.showsMenuAsPrimaryAction = false
        languageButton.clipsToBounds = true
    }

    func configureLanguageMenu() {

        langauageDropDown.dismissMode = .automatic
        langauageDropDown.dataSource = itemList
        langauageDropDown.anchorView = languageButton
        langauageDropDown.textFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        langauageDropDown.direction = .bottom

        langauageDropDown.willShowAction = { [weak self] in
            guard let self, self.languageButton.window != nil else { return }
            self.languageButton.layoutIfNeeded()

            let isIPadLandscape = self.traitCollection.userInterfaceIdiom == .pad
            && bounds.width > bounds.height

            if isIPadLandscape {
                // 아이패드 가로 → 넓게
                self.langauageDropDown.width = self.languageButton.bounds.width * 0.6

                self.langauageDropDown.bottomOffset = CGPoint(x: 0, y: self.languageButton.bounds.height - 20
                )

            } else {

                let contentWidth = self.languageButton.bounds.width * 0.3
                self.langauageDropDown.width = min(contentWidth, self.bounds.width)

                self.langauageDropDown.bottomOffset = CGPoint(x: 0, y: self.languageButton.bounds.height + 3
                )
            }
        }

        langauageDropDown.selectionAction = { [weak self] (index, item) in
            guard let self = self else { return }
            self.languageButton.setTitle(item, for: .normal)
            self.onLanguageSelected?(item)
            let name = self.itemList[index]
            if let category = CategoryRepository.allCategories.first(where: { $0.name == name }) {
                let image = UIImage(named: category.iconName)?.resized(to: .init(width: 34, height: 34))
                self.languageButton.setImage(image, for: .normal)
            } else {
                self.languageButton.setImage(nil, for: .normal)
            }
        }

        updateDropdownColors(for: languageButton.traitCollection)

        langauageDropDown.reloadAllComponents()

    }

}

#Preview() {
    MainViewController()
}
