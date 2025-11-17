//
//  UIImage+Resize.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit

extension UIImage {

    /// # Overview
    /// 주어진 크기(size)로 이미지를 리사이징하여 새로운 UIImage를 반환합니다.
    ///
    /// # Discussion
    /// - 비율 유지 없이 입력된 `CGSize` 그대로 그립니다.  
    /// - UI에서 아이콘 크기 조정, 썸네일 생성 등 간단한 용도로 사용됩니다.  
    /// - 원본 이미지는 변경되지 않으며 새로운 이미지가 반환됩니다.
    ///
    /// # Parameters
    /// - size: 생성할 이미지의 가로·세로 크기
    ///
    /// # Returns
    /// 리사이징된 새로운 UIImage 객체
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
