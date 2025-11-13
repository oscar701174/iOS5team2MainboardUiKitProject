import UIKit
import UniformTypeIdentifiers
import SwiftUI
import AVFoundation

class MyClipViewController02: UIViewController {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openFile)
        )
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

extension MyClipViewController02: UITableViewDelegate, UITableViewDataSource {
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
        let asset = AVURLAsset(url: selectedVideo.filePath)
        let playerVC = ClipPlayerViewController(url: asset, streamUrl: selectedVideo.filePath)
        navigationController?.pushViewController(playerVC, animated: true)
    }
}

extension MyClipViewController02 {
    @objc func openFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie, UTType.mpeg4Movie])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
}

extension MyClipViewController02: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // ✅ 보안 범위 접근 시작
        guard url.startAccessingSecurityScopedResource() else {
            print("접근 권한 획득 실패")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        // ✅ 앱 내부 Documents 폴더에 복사
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
/*
 struct MyClipViewController_v02Representable: UIViewControllerRepresentable {
 func makeUIViewController(context: Context) -> MyClipViewController_v02{
 MyClipViewController_v02()
 }
 
 func updateUIViewController(_ uiViewController: MyClipViewController_v02, context: Context) {
 }
 }
 
 #Preview {
 ViewControllerRepresentable()
 }
 */
