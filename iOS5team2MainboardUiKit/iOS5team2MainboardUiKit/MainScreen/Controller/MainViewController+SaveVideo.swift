//
//  MainViewController+SaveVideo.swift
//  iOS5team2MainboardUiKit
//
//  Created by cheon on 11/18/25.
//

import UIKit

/// # Overview
/// 사용자가 선택한 저장 위치(폴더)에 현재 재생 중인 영상을 복사(다운로드)하는 기능을 담당하는 확장입니다.
///
/// # Discussion
/// - iOS의 `UIDocumentPickerViewController`를 활용하여 사용자에게 "저장할 폴더"를 선택하도록 합니다.
/// - 선택된 폴더에 대해 보안 접근 권한(Security-Scoped Access)을 획득한 후,
///   현재 재생 중인 영상(`playingVideoURL`)을 해당 폴더로 복사합니다.
/// - 기존에 같은 파일명이 존재하면 자동으로 삭제 후 재저장합니다.
///
/// 이 확장은 "영상 다운로드" 기능에 대한 독립적인 책임을 가지며,
/// `MainViewController`의 핵심 로직과 분리되어 유지보수가 용이합니다.
///
/// # Note
/// DocumentPicker는 폴더 접근 시 보안 권한이 필요하므로,
/// 반드시 `startAccessingSecurityScopedResource` 호출이 필요합니다.
/// 작업 후에는 `stopAccessingSecurityScopedResource()`로 권한을 반환해야 합니다.
///
extension MainViewController: UIDocumentPickerDelegate {

    /// # Overview
    /// 사용자가 선택한 폴더에 현재 재생 중인 영상을 저장(복사)합니다.
    ///
    /// # Parameters
    /// - controller: 문서 선택기 컨트롤러
    /// - urls: 사용자가 선택한 URL 목록 (폴더 URL 1개)
    ///
    /// # Discussion
    /// 1. 사용자가 선택한 폴더 URL을 가져옵니다.
    /// 2. 해당 폴더에 대한 Security-Scoped 권한을 획득합니다.
    /// 3. 현재 재생 영상의 실제 파일 URL(`playingVideoURL`)을 가져옵니다.
    /// 4. 선택된 폴더에 `[원본파일명].mp4` 형태로 복사합니다.
    /// 5. 기존 파일이 존재하면 자동으로 삭제 후 덮어씁니다.
    ///
    /// 성공 시:
    /// ```
    /// 영상 저장 성공: /.../example.mp4
    /// ```
    /// 실패 시:
    /// ```
    /// 영상 저장 실패: (오류 내용)
    /// ```
    ///
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else { return }
        guard let sourceVideoURL = playingVideoURL else {
            print("저장 실패: videoURL 없음")
            return
        }

        // MARK: - 보안 권한 획득
        guard folderURL.startAccessingSecurityScopedResource() else {
            print("폴더 접근 권한 실패")
            return
        }
        defer { folderURL.stopAccessingSecurityScopedResource() }

        // MARK: - 저장될 파일 경로 구성
        let fileName = sourceVideoURL.lastPathComponent
        let destinationURL = folderURL.appendingPathComponent(fileName)

        // MARK: - 파일 복사 처리
        do {
            // 동일 파일 존재 시 삭제 후 대체
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.copyItem(at: sourceVideoURL, to: destinationURL)
            print("영상 저장 성공:", destinationURL.path)

        } catch {
            print("영상 저장 실패:", error.localizedDescription)
        }
    }
}
