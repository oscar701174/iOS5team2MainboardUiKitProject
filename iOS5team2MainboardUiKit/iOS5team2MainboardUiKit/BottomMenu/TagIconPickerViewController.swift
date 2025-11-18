//
//  TagIconPickerViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 여승위 on 2025/11/17.
//

import UIKit

/// # 아이콘 + 색상 + 이름을 선택할 수 있는 커스텀 태그 설정 화면
///
/// - 사용자 정의 태그를 만들 때 사용되는 ViewController입니다.
/// - 이름 입력, 아이콘 선택, 색상 선택이 가능합니다.
/// - 완료 시 콜백을 통해 결과 전달 후 종료됩니다.
final class TagIconPickerViewController: UIViewController {

    // MARK: - 타입 정의

    /// 저장 완료 시 전달할 콜백 타입
    typealias Completion = (_ name: String, _ iconName: String, _ color: UIColor) -> Void

    // MARK: - 프로퍼티

    /// 완료 시 실행되는 콜백
    private let completion: Completion

    /// 아이콘 목록 (SF Symbols)
    private let iconNames = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "camera.fill", "film.fill", "paintbrush.fill",
        "music.note", "leaf.fill"
    ]

    /// 현재 선택된 아이콘 인덱스
    private var selectedIconIndex = 0

    // MARK: - UI 구성 요소

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "커스텀 아이콘 설정"
        l.font = .boldSystemFont(ofSize: 20)
        l.textAlignment = .center
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let colorPicker: UIColorWell = {
        let cp = UIColorWell()
        cp.supportsAlpha = false
        cp.translatesAutoresizingMaskIntoConstraints = false
        return cp
    }()

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름 입력 (예: 액션)"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

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

    /// 아이콘 선택용 컬렉션 뷰
    private var iconCollection: UICollectionView!

    // MARK: - 초기화

    init(completion: @escaping Completion) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 생명주기

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupCollection()
        setupLayout()

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // 기본값
        nameField.text = "액션"
        colorPicker.selectedColor = .systemBlue
    }

    // MARK: - 레이아웃 구성

    /// 아이콘 컬렉션 뷰 구성
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

    /// 전체 레이아웃 제약 설정
    private func setupLayout() {
        [titleLabel, colorPicker, nameField, iconCollection, saveButton].forEach {
            view.addSubview($0)
        }

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

    // MARK: - 저장 버튼 동작

    /// 저장 버튼 탭 시 데이터 전달 후 화면 종료
    @objc private func saveTapped() {
        let name = (nameField.text?.isEmpty == false) ? nameField.text! : "액션"
        let iconName = iconNames[selectedIconIndex]
        let color = colorPicker.selectedColor ?? .systemBlue

        completion(name, iconName, color)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionView 설정

extension TagIconPickerViewController:
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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

// MARK: - 커스텀 아이콘 셀

/// # IconCell
/// SF Symbol 아이콘을 표시하며 선택 여부에 따라 테두리를 표시합니다.
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

    /// 셀 설정: 아이콘 이미지 및 선택 표시 테두리
    func configure(icon: String, selected: Bool) {
        iconView.image = UIImage(systemName: icon)
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
