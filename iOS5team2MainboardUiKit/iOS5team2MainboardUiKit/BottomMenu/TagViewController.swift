//
//  TagViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 여승위 on 2025/11/17.
//

import UIKit
import SwiftUI

/// # IconCategory
/// 사용자 정의 아이콘 카테고리를 표현하는 데이터 모델입니다.
///
/// - name: 사용자 지정 이름
/// - iconName: SF Symbol 이름
/// - color: 아이콘 색상
/// - isCustom: 커스텀 여부
struct IconCategory: Hashable {
    let id = UUID()
    let name: String
    let iconName: String
    let color: UIColor
    let isCustom: Bool
}

/// # CategoryCell
/// 태그 아이콘을 표시하는 UICollectionView 셀입니다.
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

    /// 셀의 UI 구성
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

    /// 셀에 모델 데이터 설정
    func configure(with category: IconCategory) {
        nameLabel.text = category.name
        iconView.image = UIImage(systemName: category.iconName)
        iconView.tintColor = category.color
        containerView.backgroundColor = .systemBackground
    }

    /// 셀 선택 상태 시 테두리 강조
    override var isSelected: Bool {
        didSet {
            containerView.layer.borderWidth = isSelected ? 2 : 0
            containerView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }
}

/// # TagViewController
/// 사용자가 커스텀 태그 아이콘을 생성, 선택, 삭제할 수 있는 화면입니다.
///
/// - 커스텀 태그를 리스트로 보여줌
/// - 새 태그 추가를 위한 모달 제공
/// - 선택 시 삭제 가능
final class TagViewController: UIViewController {

    private var customCategories: [IconCategory] = []
    private var selectedIndexPath: IndexPath?
    private var collectionView: UICollectionView!

    // MARK: - 하단 버튼 및 라벨 구성

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
        stack.distribution = .fillEqually
        stack.spacing = 12
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

    // MARK: - 생명주기

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupBottomViews()
    }

    // MARK: - CollectionView 설정

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

    // MARK: - 하단 UI 설정

    private func setupBottomViews() {
        view.addSubview(infoLabel)
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(customButton)
        buttonStack.addArrangedSubview(deleteButton)

        let fixedWidth: CGFloat = 360

        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.widthAnchor.constraint(equalToConstant: fixedWidth),

            buttonStack.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -16),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: fixedWidth),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20)
        ])

        customButton.addTarget(self, action: #selector(openCustomModal), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)
    }

    // MARK: - 모달 열기

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

// MARK: - CollectionView Delegate & FlowLayout

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

    /// 셀 크기 계산 (기기 및 방향 대응)
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
