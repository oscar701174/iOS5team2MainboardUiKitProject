import UIKit
import UniformTypeIdentifiers
import SwiftUI
import AVFoundation

class MyClipViewController: UIViewController {
    private let clipTableView = UITableView()
    private var nowPlayingVideo: VideoModel? {
        didSet {
            print("nowPlayingVideo: \(String(describing: nowPlayingVideo))")
            guard let video = nowPlayingVideo else {
                playerView = nil
                return
            }
            playerView = ClipPlayerView(video: video)
        }
    }
    private var playerView: ClipPlayerView? {
        didSet {
            // Remove old playerView
            oldValue?.removeFromSuperview()
            // Add new playerView if available
            if let playerView = playerView {

                playerView.delegate = self
                playerView.translatesAutoresizingMaskIntoConstraints = false
                playerContainer.addSubview(playerView)
                NSLayoutConstraint.activate([
                    playerView.topAnchor.constraint(equalTo: playerContainer.topAnchor),
                    playerView.leadingAnchor.constraint(equalTo: playerContainer.leadingAnchor),
                    playerView.trailingAnchor.constraint(equalTo: playerContainer.trailingAnchor),
                    playerView.bottomAnchor.constraint(equalTo: playerContainer.bottomAnchor),
                    playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0/16.0)
                ])
            }
        }
    }
    private let playerContainer = UIView()
    private var videos: [VideoModel] = [] {
        didSet {
            clipTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Clips"
        view.backgroundColor = .systemBackground
        setupLayout()
        setupTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openFile)
        )
    }
    private func setupLayout() {
        clipTableView.translatesAutoresizingMaskIntoConstraints = false
        playerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clipTableView)
        view.addSubview(playerContainer)
        NSLayoutConstraint.activate([
            // Table on top
            clipTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            clipTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            clipTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // Player container below table
            playerContainer.topAnchor.constraint(equalTo: clipTableView.bottomAnchor),
            playerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            playerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func setupTableView() {
        clipTableView.dataSource = self
        clipTableView.delegate = self
        clipTableView.register(UITableViewCell.self, forCellReuseIdentifier: "clipTable")
    }
}

extension MyClipViewController: UITableViewDelegate, UITableViewDataSource {
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
        let video = videos[indexPath.row]
        nowPlayingVideo = video
    }
}

extension MyClipViewController {
    @objc func openFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie, UTType.mpeg4Movie])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
}

extension MyClipViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else {
            print("접근 권한 획득 실패")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        let fileName = url.lastPathComponent
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        print("destinationURL")
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("✅ 복사 완료:", destinationURL.path)
            self.videos.append(VideoModel(title: fileName, filePath: destinationURL, clips: nil))
        } catch {
            print("파일 복사 실패:", error)
        }
    }
}

extension MyClipViewController: ClipPlayerViewDelegate {
    func clipPlayerViewDidAttach(_ view: ClipPlayerView, container: UIView) {
        // Optional: handle attachment events
    }
}

struct MyClipViewController02Representable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MyClipViewController {
        MyClipViewController()
    }
    func updateUIViewController(_ uiViewController: MyClipViewController, context: Context) {
    }
}

#Preview {
    MyClipViewController02Representable()
}
