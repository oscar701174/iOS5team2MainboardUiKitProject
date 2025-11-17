//
//  PlayerView.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/10/25.
//

import UIKit
import AVFoundation

/// # Overview
/// AVPlayer 전용 레이어를 사용하는 커스텀 UIView입니다.
///
/// # Discussion
/// iOS에서 영상 재생 UI를 구성할 때 일반 `UIView`는 `CALayer`를 기본으로 가지지만,  
/// 실제 영상은 `AVPlayerLayer`에서만 렌더링할 수 있습니다.
///
/// `PlayerView`는 UIView의 기본 레이어 타입을 `AVPlayerLayer`로 바꿔  
/// 외부에서 단순히 `playerView.player = AVPlayer(...)` 형태로  
/// 손쉽게 재생 화면을 구성할 수 있도록 설계된 클래스입니다.
///
/// # Usage
/// ```swift
/// let view = PlayerView()
/// view.player = AVPlayer(url: url)
/// ```
///
/// # Note
/// 이 클래스는 UI를 위한 Wrapper일 뿐 별도의 재생 제어 기능은 포함하지 않습니다.
/// 재생 로직은 `VideoPlayerManager`와 같은 별도 매니저에서 관리해야 합니다.
class PlayerView: UIView {

    /// # Overview
    /// UIView가 사용할 레이어 타입을 `AVPlayerLayer`로 지정합니다.
    ///
    /// # Discussion
    /// 기본 UIView는 `CALayer`를 사용하지만 영상 렌더링을 위해  
    /// 이 타입을 override해 `AVPlayerLayer`로 교체합니다.
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    /// # Overview
    /// 이 뷰의 레이어를 `AVPlayerLayer` 타입으로 안전하게 캐스팅한 프로퍼티입니다.
    ///
    /// # Discussion
    /// 타입이 다른 레이어가 들어오는 상황은 설계상 존재하지 않지만,  
    /// 안전성을 위해 guard 문으로 타입을 보장합니다.
    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            preconditionFailure("Expected AVPlayerLayer, got \(type(of: layer))")
        }
        return layer
    }

    /// # Overview
    /// 현재 PlayerView에서 재생할 AVPlayer 인스턴스입니다.
    ///
    /// # Discussion
    /// 내부적으로는 `playerLayer.player` 값을 그대로 반환합니다.  
    /// UI에 플레이어를 연결하는 역할만 수행하며 제어는 외부 매니저에게 맡깁니다.
    ///
    /// # Example
    /// ```swift
    /// playerView.player = someAVPlayer
    /// ```
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}
