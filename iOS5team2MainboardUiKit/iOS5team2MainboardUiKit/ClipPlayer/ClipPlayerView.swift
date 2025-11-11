import SwiftUI
import UIKit
import AVFoundation


class ClipPlayerView: UIView {
    let containerView = UIView()
    let clipPlayer = ClipPlayerController()
    weak var delegate: ClipPlayerViewDelegate?
    
    init(video: Video) {
        super.init(frame: .zero)
        // Safely unwrap delegate as UIViewController and pass non-optional to embedInline
        setupUI()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            containerView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let clipVC = delegate as? UIViewController {
            clipPlayer.embedInline(in: clipVC, container: containerView)
        } else {
            print(self,#function,"delegate is not UIViewController")
        }
        
    }
    
    
}

protocol ClipPlayerViewDelegate: AnyObject {
    func clipPlayerViewDidAttach(_ view: ClipPlayerView, container: UIView)
}


// MARK: - SwiftUI Preview
struct ClipPlayerViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ClipPlayerView {
        return ClipPlayerView(video: Video(title: "sample", hlsUrl: URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!))
    }
    
    func updateUIView(_ uiView: ClipPlayerView, context: Context) {
        // 상태 업데이트가 필요할 경우 여기에 작성
    }
}

#Preview {
    ClipPlayerViewRepresentable()
        .frame(width: 200, height: 200)
}
