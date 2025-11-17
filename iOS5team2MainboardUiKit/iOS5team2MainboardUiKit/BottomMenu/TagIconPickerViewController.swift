//
//  TagIconPickerViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 여승위 on 2025/11/17.
//

import UIKit

/// # TagIconPickerViewController
/// 커스텀 태그 아이콘을 생성하기 위한 팝업 화면입니다.
///
/// - 아이콘 이름 입력
/// - 색상 선택
/// - SF Symbols 중 아이콘 선택
/// - 저장 시 콜백으로 결과 전달
final class TagIconPickerViewController: UIViewController {

    /// 사용자 입력 완료 시 전달할 콜백 타입
    typealias Completion = (_ name: String, _ iconName: String, _ color: UIColor) -> Void

    private let completion: Completion

    /// 사용할 SF Symbols 목록
    private let iconNames = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "camera.fill", "film.fill", "paintbrush.fill",
        "music.note", "leaf.fill"
    ]
    private var selectedIconIndex = 0

    // MARK: - UI 컴포넌트

    /// 상단 타이틀 라벨
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "커스텀 아이콘 설정"
        l.font = .boldSystemFont(ofSize: 20)
        l.textAlignment = .center
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    /// 색상 선택기
    private let colorPicker: UIColorWell = {
        let cp = UIColorWell()
        cp.supportsAlpha = false
        cp.translatesAutoresizingMaskIntoConstraints = false
        return cp
    }()

    /// 이름 입력 필드
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름 입력 (예: 액션)"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    /// 저장 버튼
    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("저장하기", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    /// 아이콘 선택 컬렉션 뷰
    private var iconCollection: UICollectionView!

    // MARK: - Init

    init(completion: @escaping Completion) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - 생명주기

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupCollection()
        setupLayout()

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // 기본값 설정
        nameField.text = "액션"
        colorPicker.selectedColor = .systemBlue
    }

    // MARK: - 아이콘 컬렉션 뷰 설정

    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        iconCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        iconCollection.backgroundColor = .clear
        iconCollection.translatesAutoresizingMaskIntoConstraints = false
        iconCollection.showsHorizontalScrollIndicator = false
        iconCollection.delegate = self
        iconCollection.dataSource = self
        iconCollection.register(IconCell.self, forCellWithReuseIdentifier: "IconCell")
    }

    // MARK: - 전체 UI 레이아웃 구성

    private func setupLayout() {
        [titleLabel, colorPicker, nameField, iconCollection, saveButton]
            .forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            colorPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameField.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            iconCollection.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            iconCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            iconCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            iconCollection.heightAnchor.constraint(equalToConstant: 60),

            saveButton.topAnchor.constraint(equalTo: iconCollection.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // MARK: - 저장 동작

    @objc private func saveTapped() {
        let name = (nameField.text?.isEmpty == false) ? nameField.text! : "액션"
        let iconName = iconNames[selectedIconIndex]
        let color = colorPicker.selectedColor ?? .systemBlue

        completion(name, iconName, color)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionView Delegate / DataSource / FlowLayout

extension TagIconPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        iconNames.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "IconCell",
            for: indexPath
        ) as! IconCell

        let name = iconNames[indexPath.item]
        cell.configure(icon: name, selected: indexPath.item == selectedIconIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIconIndex = indexPath.item
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 50, height: 50)
    }
}

/// # IconCell
/// SF Symbol을 표시하는 단일 아이콘 셀입니다.
final class IconCell: UICollectionViewCell {

    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label

        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.clear.cgColor

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    /// 셀의 표시할 아이콘과 선택 여부 설정
    func configure(icon: String, selected: Bool) {
        iconView.image = UIImage(systemName: icon)
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

