import UIKit

// MARK: - 데이터 구조
struct Category {
    let name: String
    let iconName: String // 이미지 이름 (Assets에 추가)
}

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

    let categories: [Category] = [
        Category(name: "Kotlin", iconName: "KotlinLogo"),
        Category(name: "PHP", iconName: "PHPLogo"),
        Category(name: "Node.js", iconName: "NoSQLLogo"),
        Category(name: "Java", iconName: "JavaLogo"),
        Category(name: "C", iconName: "cLogo"),
        Category(name: "Docker", iconName: "DockerLogo"),
        Category(name: "JavaScript", iconName: "JavaScriptLogo"),
        Category(name: "Angular", iconName: "AngularLogo"),
        Category(name: "Swift", iconName: "swiftLogo"),
        Category(name: "Django", iconName: "DjangoLogo"),
        Category(name: "Kubernetes", iconName: "KubernetesLogo"),
        Category(name: "Spring", iconName: "SpringLogo"),
        Category(name: "Python", iconName: "PythonLogo"),
        Category(name: "React", iconName: "ReactLogo"),
        Category(name: "Vue", iconName: "VuejsLogo")
    ]

    private var collectionView: UICollectionView!

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
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
