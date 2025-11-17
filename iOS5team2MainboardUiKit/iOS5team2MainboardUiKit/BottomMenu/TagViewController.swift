//
//  TagViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 여승위 on 2025/11/17.
//

import UIKit
import SwiftUI

// MARK: - 셀 클래스
final class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"

    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let verticalStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        verticalStack.axis = .vertical
        verticalStack.alignment = .center
        verticalStack.spacing = 6
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 30
        iconImageView.layer.masksToBounds = true

        nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        verticalStack.addArrangedSubview(iconImageView)
        verticalStack.addArrangedSubview(nameLabel)

        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60)
        ])

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowRadius = 3
    }

    func configure(with category: Category) {
        iconImageView.image = UIImage(named: category.iconName)
        nameLabel.text = category.name
    }

    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 2 : 0
            contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }
}

// MARK: - 태그 선택 화면
final class TagViewController: UIViewController {

    private let categories = CategoryRepository.allCategories
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

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "원하는 아이콘을 선택해 주세요\n취향을 맞춰 동영상을 제공하기 위한 작업입니다."
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 1️⃣ 버튼 & 라벨을 먼저 addSubview
        view.addSubview(customButton)
        view.addSubview(infoLabel)

        setupInfoLabel()
        setupCustomButton()

        // 2️⃣ 이후에 collectionView 생성 + 제약 적용
        setupCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
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

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // 이제 customButton은 이미 view에 있으므로 충돌 없음
            collectionView.bottomAnchor.constraint(equalTo: customButton.topAnchor, constant: -20)
        ])
    }

    private func setupCustomButton() {
        NSLayoutConstraint.activate([
            customButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            customButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            customButton.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -20),
            customButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        customButton.addTarget(self, action: #selector(openCustomModal), for: .touchUpInside)
    }

    private func setupInfoLabel() {
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }

    @objc private func openCustomModal() {
        let customModal = CustomSettingViewController()
        customModal.modalPresentationStyle = .pageSheet
        if let sheet = customModal.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(customModal, animated: true)
    }
}

// MARK: - CollectionView Delegate
extension TagViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: categories[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let isIPhone = traitCollection.userInterfaceIdiom == .phone
        let columns: CGFloat = isIPhone ? 4 : 3

        let spacing: CGFloat = (columns - 1) * 12
        let sideInsets: CGFloat = 20 + 20
        let availableWidth = collectionView.bounds.width - spacing - sideInsets

        let width = floor(availableWidth / columns)
        return CGSize(width: width, height: width + 24)
    }
}

// MARK: - 커스텀 모달
final class CustomSettingViewController: UIViewController {

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "커스텀 아이콘 설정"
        lbl.font = .boldSystemFont(ofSize: 20)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let colorPicker = UIColorWell()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "아이콘 텍스트 입력"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장하기", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(colorPicker)
        view.addSubview(textField)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            colorPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textField.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 30),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            saveButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - Preview
struct TagView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TagViewController { TagViewController() }
    func updateUIViewController(_ uiViewController: TagViewController, context: Context) {}
}

#Preview {
    TagViewController()
}
