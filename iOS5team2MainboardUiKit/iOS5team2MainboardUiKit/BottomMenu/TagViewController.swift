//
//  TagViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 여승위 on 2025/11/17.
//

import UIKit
import SwiftUI

// MARK: - 아이콘 카테고리 모델
struct IconCategory: Hashable {
    let id = UUID()
    let name: String
    let iconName: String
    let color: UIColor
    let isCustom: Bool
}

// MARK: - 셀 클래스
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
        containerView.backgroundColor = .systemBackground
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
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 70),
            containerView.heightAnchor.constraint(equalToConstant: 70),

            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with category: IconCategory) {
        nameLabel.text = category.name
        iconView.image = UIImage(systemName: category.iconName)
        iconView.tintColor = category.color
        containerView.backgroundColor = .systemBackground
    }

    override var isSelected: Bool {
        didSet {
            containerView.layer.borderWidth = isSelected ? 2 : 0
            containerView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }
}

// MARK: - 태그 선택 화면
final class TagViewController: UIViewController {

    private var customCategories: [IconCategory] = []
    private var selectedIndexPath: IndexPath?
    private var collectionView: UICollectionView!

    private let customButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("커스텀 아이콘 만들기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제하기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "아이콘을 직접 만들어 주세요.\n동영상 취향 추천에 사용됩니다."
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupBottomViews()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
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
        view.addSubview(infoLabel)
        view.addSubview(buttonStack)

        buttonStack.addArrangedSubview(customButton)
        buttonStack.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            buttonStack.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -16),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20)
        ])

        customButton.addTarget(self, action: #selector(openCustomModal), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)
    }

    @objc private func openCustomModal() {
        let modal = TagIconPickerViewController { [weak self] name, iconName, color in
            guard let self else { return }

            let newItem = IconCategory(name: name, iconName: iconName, color: color, isCustom: true)
            self.customCategories.append(newItem)
            self.collectionView.reloadData()
        }

        modal.modalPresentationStyle = .pageSheet
        modal.preferredContentSize = CGSize(width: 0, height: 330)

        if let sheet = modal.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in modal.preferredContentSize.height }
                ]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }

        present(modal, animated: true)
    }

    // MARK: - 삭제 처리
    @objc private func confirmDelete() {
        guard let indexPath = selectedIndexPath else { return }

        let alert = UIAlertController(
            title: "삭제 확인",
            message: "선택한 아이콘을 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.customCategories.remove(at: indexPath.item)
            self.selectedIndexPath = nil
            self.deleteButton.isEnabled = false
            self.collectionView.reloadData()
        })

        present(alert, animated: true)
    }
}

// MARK: - CollectionView Delegate/DataSource
extension TagViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        customCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else { return UICollectionViewCell() }

        cell.configure(with: customCategories[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        deleteButton.isEnabled = true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPath = nil
        deleteButton.isEnabled = false
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 12 * 3
        let totalInset: CGFloat = 40
        let columns: CGFloat = traitCollection.userInterfaceIdiom == .pad ? 6 : 4
        let availableWidth = collectionView.bounds.width - spacing - totalInset
        let width = floor(availableWidth / columns)

        return CGSize(width: width, height: width + 20)
    }
}

#Preview {
    TagViewController()
}
