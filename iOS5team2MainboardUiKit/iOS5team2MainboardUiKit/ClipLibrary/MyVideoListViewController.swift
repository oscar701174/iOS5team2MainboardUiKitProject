import UIKit
import UniformTypeIdentifiers
import SwiftUI
import AVFoundation

class MyVideoListViewController: UIViewController {
    let videoManager = VideoManager()
    private let clipTableView = UITableView()
    private let button = UIButton(configuration: .glass())
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

        // 초기 로드 시에도 번들/문서 URL 모두 대응하도록 통일
        let fetched = videoManager.fetch()
        self.videos = fetched.compactMap { entity in
            // 번들 URL이 없으면 CoreData에 저장된 문자열 URL 사용
            guard let resolvedURL = videoManager.bundleURL(for: entity) ?? URL(string: entity.url ?? "") else { return nil }
            // Map clips relationship (NSSet -> [ClipModel])
            let clipModels: [ClipModel] = (entity.clips as? Set<ClipEntity>)?.map {
                ClipModel(
                    start: $0.startSeconds,
                    end: $0.endSeconds,
                    title: $0.title
                )
            } ?? []
            return VideoModel(
                title: entity.title ?? "",
                filePath: resolvedURL,
                clips: clipModels
            )
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openFile)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면 복귀 시 항상 최신 Core Data 상태로 동기화
        let fetched = videoManager.fetch()
        self.videos = fetched.compactMap { entity in
            guard let resolvedURL = videoManager.bundleURL(for: entity) ?? URL(string: entity.url ?? "") else { return nil }
            let clipModels: [ClipModel] = (entity.clips as? Set<ClipEntity>)?.map {
                ClipModel(
                    start: $0.startSeconds,
                    end: $0.endSeconds,
                    title: $0.title
                )
            } ?? []
            return VideoModel(title: entity.title ?? "", filePath: resolvedURL, clips: clipModels)
        }
    }

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

extension MyVideoListViewController {
    @objc func openFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie, UTType.mpeg4Movie])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
}

extension MyVideoListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // 보안 범위 접근 시작
        guard url.startAccessingSecurityScopedResource() else {
            print("접근 권한 획득 실패")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // 앱 내부 Documents 폴더에 복사
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

            self.videos.append(VideoModel(title: fileName, filePath: destinationURL))

            // MARK: CoreData - VideoEntity 생성
            videoManager.create(
                title: fileName,
                url: destinationURL.absoluteString,
                tag: "",
                text: ""
            )

            // 생성 직후 최신 상태로 재-fetch (번들/문서 모두 대응)
            let fetched = videoManager.fetch()
            self.videos = fetched.compactMap { entity in
                guard let resolvedURL = videoManager.bundleURL(for: entity) ?? URL(string: entity.url ?? "") else { return nil }
                let clipModels: [ClipModel] = (entity.clips as? Set<ClipEntity>)?.map {
                    ClipModel(
                        start: $0.startSeconds,
                        end: $0.endSeconds,
                        title: $0.title
                    )
                } ?? []
                return VideoModel(title: entity.title ?? "", filePath: resolvedURL, clips: clipModels)
            }
        } catch {
            print("파일 복사 실패:", error)
        }
    }
}
