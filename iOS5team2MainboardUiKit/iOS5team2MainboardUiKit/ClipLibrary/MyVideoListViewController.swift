import UIKit
import UniformTypeIdentifiers
import SwiftUI
import AVFoundation

/// # MyVideoListViewController
/// 사용자가 저장한 영상 리스트를 보여주고, 클립 재생 화면으로 이동할 수 있는 화면입니다.
/// - CoreData에서 저장된 영상 정보를 불러오고, TableView로 목록을 표시합니다.
/// - 새 영상 파일을 가져올 수 있는 파일 선택 기능도 지원합니다.
class MyVideoListViewController: UIViewController {

    let videoManager = VideoManager()  // CoreData 영상 관리 매니저
    private let clipTableView = UITableView()
    private let button = UIButton(configuration: .glass())

    /// 현재 보여지는 영상 목록
    private var videos: [VideoModel] = [] {
        didSet {
            clipTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Clips"
        view.backgroundColor = .systemBackground

        setupTableView()

        // CoreData에서 영상 불러오기 및 매핑
        let fetched = videoManager.fetch()
        self.videos = fetched.compactMap { entity in
            guard let url = videoManager.bundleURL(for: entity) else { return nil }

            // 관계된 클립 정보 매핑 (CoreData → Model)
            let clipModels: [ClipModel] = (entity.clips as? Set<ClipEntity>)?.map {
                ClipModel(start: $0.startSeconds, end: $0.endSeconds, title: $0.title)
            } ?? []

            return VideoModel(
                title: entity.title ?? "",
                filePath: url,
                tag: entity.tag ?? "",
                clips: clipModels
            )
        }

        // 파일 추가 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openFile)
        )
    }

    /// 테이블뷰 기본 설정 및 레이아웃 설정
    func setupTableView() {
        view.addSubview(clipTableView)
        clipTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            clipTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            clipTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            clipTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            clipTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        clipTableView.dataSource = self
        clipTableView.delegate = self
        clipTableView.register(UITableViewCell.self, forCellReuseIdentifier: "clipTable")
    }
}

// MARK: - TableView Delegate & DataSource
extension MyVideoListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = clipTableView.dequeueReusableCell(withIdentifier: "clipTable", for: indexPath)
        cell.textLabel?.text = videos[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideo = videos[indexPath.row]
        let playerVC = ClipPlayerViewController(video: selectedVideo)
        navigationController?.pushViewController(playerVC, animated: true)
    }
}

// MARK: - 파일 열기 및 가져오기
extension MyVideoListViewController {

    /// 영상 파일 선택 화면 열기
    @objc func openFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie, UTType.mpeg4Movie])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
}

// MARK: - 파일 선택 결과 처리
extension MyVideoListViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        // 파일 접근 권한 확보
        guard url.startAccessingSecurityScopedResource() else {
            print("접근 권한 획득 실패")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // Documents 폴더로 복사
        let fileName = url.lastPathComponent
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        print("destinationURL")

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("복사 완료:", destinationURL.path)

            // 즉시 목록에 반영 (임시)
            self.videos.append(
                VideoModel(title: fileName, filePath: destinationURL, tag: "", clips: [])
            )

            // CoreData에 저장
            videoManager.create(
                title: fileName,
                url: destinationURL.absoluteString,
                tag: "",
                text: ""
            )

            // CoreData 다시 불러오기 (동기화)
            let fetched = videoManager.fetch()
            self.videos = fetched.compactMap { entity in
                guard let resolvedURL = videoManager.bundleURL(for: entity) ?? URL(string: entity.url ?? "") else { return nil }

                let clipModels: [ClipModel] = (entity.clips as? Set<ClipEntity>)?.map {
                    ClipModel(start: $0.startSeconds, end: $0.endSeconds, title: $0.title)
                } ?? []

                return VideoModel(
                    title: entity.title ?? "",
                    filePath: resolvedURL,
                    tag: entity.tag ?? "",
                    clips: clipModels
                )
            }
        } catch {
            print("파일 복사 실패:", error)
        }
    }
}
