import UIKit

final class TagIconPickerViewController: UIViewController {

    typealias Completion = (_ name: String, _ iconName: String, _ color: UIColor) -> Void
    private let completion: Completion

    // 사용할 SF Symbols 목록
    private let iconNames = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "camera.fill", "film.fill", "paintbrush.fill",
        "music.note", "leaf.fill"
    ]
    private var selectedIconIndex = 0

    // UI
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

    private var iconCollection: UICollectionView!

    // MARK: Init
    init(completion: @escaping Completion) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupCollection()
        setupLayout()

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        nameField.text = "액션"
        colorPicker.selectedColor = .systemBlue
    }

    // MARK: Setup - 아이콘 컬렉션뷰
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

    // MARK: Setup - Layout
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

    // MARK: Action
    @objc private func saveTapped() {
        let name = (nameField.text?.isEmpty == false) ? nameField.text! : "액션"
        let iconName = iconNames[selectedIconIndex]
        let color = colorPicker.selectedColor ?? .systemBlue

        completion(name, iconName, color)
        dismiss(animated: true)
    }
}

// MARK: - Collection Delegate
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

// MARK: - 아이콘 셀
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

    func configure(icon: String, selected: Bool) {
        iconView.image = UIImage(systemName: icon)
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) { fatalError() }
}

