//
//  ThumnailManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import AVFoundation
import UIKit

/// AVAsset 기반으로 지정된 시점의 영상 썸네일 이미지를 생성하는 유틸리티.
///
/// 비동기 방식으로 CGImage를 추출하여 UIImage로 변환해 반환한다.
/// 셀 썸네일, 리스트 미리보기 등에서 사용된다.
enum ThumnailManager {

    /// # Overview
    /// 주어진 영상 URL에서 특정 시점(time)의 프레임을 추출해 UIImage로 반환한다.
    ///
    /// # Discussion
    /// - 기본 추출 위치는 영상 시작 후 1초 지점이다.  
    /// - `AVAssetImageGenerator`를 사용하여 비동기적으로 이미지 생성.  
    /// - `requestedTimeToleranceBefore/After = .zero` 설정으로 최대한 정확한 프레임을 요청한다.  
    /// - 결과는 메인 스레드에서 반환되므로 UI 업데이트에 바로 사용 가능하다.
    ///
    /// # Parameters
    /// - url: 썸네일을 생성할 영상 URL
    /// - time: 추출할 시점 (`CMTime`). 기본값은 1초 지점
    /// - completion: 추출된 UIImage 또는 실패 시 nil을 반환하는 클로저
    ///
    /// # Note
    /// 파일이 없거나 손상된 경우 nil이 반환되며, 콘솔에 오류 메시지가 출력된다.
    static func generateThumnail(
        from url: URL,
        at time: CMTime = CMTime(seconds: 1, preferredTimescale: 600),
        completion: @escaping (UIImage?) -> Void
    ) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        // 영상을 회전된 상태로 찍히지 않게 원본 트랙의 방향 정보를 반영
        imageGenerator.appliesPreferredTrackTransform = true

        // 요청된 시간 기준으로 정확한 프레임을 가져오도록 설정
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero

        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
            _, cgImage, _, _, error in

            DispatchQueue.main.async {
                if let cgImage {
                    completion(UIImage(cgImage: cgImage))
                } else {
                    print("Error generating thumbnail: \(String(describing: error))")
                    completion(nil)
                }
            }
        }
    }
}
