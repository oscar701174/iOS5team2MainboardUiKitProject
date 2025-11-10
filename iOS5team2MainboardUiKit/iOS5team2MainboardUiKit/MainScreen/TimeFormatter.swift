//
//  TimeFormatter.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/10/25.
//

import Foundation
enum TimeFormatter {
   static func timeFormat(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "--:--" }

        let totalSeconds = Int(seconds.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secondsRemainder = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, secondsRemainder)

    }
}
