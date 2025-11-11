//
//  UIImage+Resize.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
