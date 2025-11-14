//
//  ThumnailManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import AVFoundation
import UIKit


enum ThumnailManager {
    static func generateThumnail(from url: URL, at time: CMTime = CMTime(seconds: 1, preferredTimescale: 600), completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        imageGenerator.appliesPreferredTrackTransform = true

        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero

        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, _, error in
            DispatchQueue.main.async {
                if let cgImage = cgImage {
                    let image = UIImage(cgImage: cgImage)
                    completion(image)
                } else {
                    print("Error generating thumbnail: \(String(describing: error))")
                    completion(nil)
                }
            }
        }
    }
}
