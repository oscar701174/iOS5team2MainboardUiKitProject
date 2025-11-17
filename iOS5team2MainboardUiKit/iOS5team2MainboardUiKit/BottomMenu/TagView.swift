import UIKit
import SwiftUI // Preview용(김대현)

// MARK: - 데이터 구조
// struct Category {
//    let name: String
//    let iconName: String // 이미지 이름 (Assets에 추가)
// }

// MARK: - 셀 클래스
class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"

    private let containerView = UIView()
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // 컨테이너 뷰 (둥근 카드형)
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 35
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false

        // 아이콘 이미지
        containerView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 70),
            containerView.heightAnchor.constraint(equalToConstant: 70),

            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func configure(with category: Category) {
        iconView.image = UIImage(named: category.iconName)
    }

    // 선택 효과 (테두리 색상)
    override var isSelected: Bool {
        didSet {
            containerView.layer.borderWidth = isSelected ? 2 : 0
            containerView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }
}

// MARK: - 메인 ViewController
class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let categories: [Category] = CategoryRepository.allCategories
    private var collectionView: UICollectionView!
    private let customButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("커스텀 아이콘 만들기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
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
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupInfoLabel()
        setupCustomButton()
    }

    // MARK: - CollectionView 설정
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 25

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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    private func setupCustomButton() {
        view.addSubview(customButton)
        customButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customButton.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -20),
            customButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            customButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            customButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        customButton.addTarget(self, action: #selector(openCustomModal), for: .touchUpInside)
    }
    @objc private func openCustomModal() {
        let vc = CustomSettingViewController()
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(vc, animated: true)
    }
    // MARK: - 하단 안내문
    private func setupInfoLabel() {
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - CollectionView Delegate / DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: categories[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = categories[indexPath.item]
        print("✅ 선택된 아이콘: \(selected.name)")
    }
}

// Preview용 (김대현)
struct TagView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CategoryViewController {
        return CategoryViewController()
    }

    func updateUIViewController(_ uiViewController: CategoryViewController, context: Context) {
    }
}
#Preview {
    TagView()
}
class CustomSettingViewController: UIViewController {

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "커스텀 아이콘 설정"
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textAlignment = .center
        return lbl
    }()

    private let colorPicker = UIColorWell()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "아이콘 텍스트 입력"
        return tf
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장하기", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
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

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

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
