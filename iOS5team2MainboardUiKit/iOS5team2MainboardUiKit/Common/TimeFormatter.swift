//
//  TimeFormatter.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/10/25.
//

import Foundation

/// 재생 시간을 `"HH:MM:SS"` 형태의 문자열로 변환하는 유틸리티.
///
/// AVPlayer 재생 시간, 슬라이더 표시 텍스트 등에서 공통적으로 사용됩니다.
enum TimeFormatter {

    /// # Overview
    /// 초 단위의 시간을 `"HH:MM:SS"` 형식의 문자열로 변환합니다.
    ///
    /// # Discussion
    /// - 시간은 정수로 반올림하여 처리합니다.  
    /// - 유효하지 않은 값(`NaN`, 음수 등)이 들어올 경우 `"--:--"`을 반환합니다.  
    /// - 1시간 미만의 경우에도 항상 `00:` 형식으로 맞춰 출력합니다.
    ///
    /// # Parameters
    /// - seconds: 변환할 시간(초). `Double` 형태.
    ///
    /// # Returns
    /// `"HH:MM:SS"` 형식의 문자열
    static func timeFormat(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "--:--" }

        let totalSeconds = Int(seconds.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secondsRemainder = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, secondsRemainder)
    }
}
