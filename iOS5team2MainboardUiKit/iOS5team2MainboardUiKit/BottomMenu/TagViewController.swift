//
//  TagViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 여승위 on 2025/11/17.
//

import UIKit
import SwiftUI

final class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"

    private let containerView = UIView()
    private let iconView = UIImageView()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 35
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false

        containerView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 70),
            containerView.heightAnchor.constraint(equalToConstant: 70),

            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func configure(with category: Category) {
        iconView.image = UIImage(named: category.iconName)
        nameLabel.text = category.name
    }

    override var isSelected: Bool {
        didSet {
            containerView.layer.borderWidth = isSelected ? 2 : 0
            containerView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }
}

final class TagViewController: UIViewController {

    let categories: [Category] = CategoryRepository.allCategories
    private var collectionView: UICollectionView!

    private let customButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("커스텀 아이콘 만들기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "원하는 아이콘을 선택해 주세요\n취향을 맞춰 동영상을 제공하기 위한 작업입니다."
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupBottomViews()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)

        view.addSubview(collectionView)
    }

    private func setupBottomViews() {
        view.addSubview(customButton)
        view.addSubview(infoLabel)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            customButton.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -16),
            customButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            customButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            customButton.heightAnchor.constraint(equalToConstant: 50),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: customButton.topAnchor, constant: -20)
        ])

        customButton.addTarget(self, action: #selector(openCustomModal), for: .touchUpInside)
    }

    @objc private func openCustomModal() {
        if #available(iOS 15.0, *) {
            let modalVC = UIViewController()
            modalVC.view.backgroundColor = .systemGroupedBackground
            modalVC.modalPresentationStyle = .pageSheet
            if let sheet = modalVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            present(modalVC, animated: true)
        } else {
            let fallbackVC = UIViewController()
            fallbackVC.view.backgroundColor = .white
            fallbackVC.modalPresentationStyle = .fullScreen
            present(fallbackVC, animated: true)
        }
    }
}

extension TagViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: categories[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let itemsPerRow: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 6 : 4
        let spacing: CGFloat = 10 * (itemsPerRow - 1)
        let totalPadding: CGFloat = 40 // 20 leading + 20 trailing
        let itemWidth = (screenWidth - spacing - totalPadding) / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth + 20)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = categories[indexPath.item]
        print("✅ 선택된 아이콘: \(selected.name)")
    }
}

#Preview {
    TagViewController()
}
