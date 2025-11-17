<p align="center">
  <img src="https://private-user-images.githubusercontent.com/235646571/515226174-43646164-82f9-477b-b110-2153a42167ba.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NjMzOTEwMjYsIm5iZiI6MTc2MzM5MDcyNiwicGF0aCI6Ii8yMzU2NDY1NzEvNTE1MjI2MTc0LTQzNjQ2MTY0LTgyZjktNDc3Yi1iMTEwLTIxNTNhNDIxNjdiYS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUxMTE3JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MTExN1QxNDQ1MjZaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT02M2E2OTVkMzZlY2M5NmZiNjY1M2U4ZGE0NzRkYjIyNTA1NGNjMzRiZjdhMTQwNzU4ZjUzNDE1ZTU2MzVhM2NjJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.csqVmXrjN7lBXd_b46Q06iXIrO7uH9vk6FNUB9VfY9s" width="100%">
</p>

<br>

<h1 align="center">앱 이름 미정</h1>

<p align="center">
  <b>강의 영상을 더 효과적으로 시청하고, 필요한 순간을 바로 저장할 수 있는 학습용 영상 플레이어</b>
</p>

<br>

## 📱 프로젝트 개요 (Overview)

**Mainboard는 강의 영상을 빠르게 탐색하고, 필요한 구간을 ‘클립’으로 저장해 다시 확인할 수 있는 UIKit 기반 영상 플레이어입니다.**  
언어 선택, 검색, 15초 이동, 전체화면 재생 등 강의 시청에 필요한 다양한 기능을 제공하며,  
중요한 학습 구간을 손쉽게 저장하고 관리할 수 있도록 설계되었습니다.

> **"학습에 필요한 순간을 놓치지 않고 저장하는 플레이어."**

Mainboard는 사용자가 강의 영상을 더 효과적으로 보고,  
원하는 부분을 빠르게 찾아 다시 볼 수 있도록 돕는 앱입니다.


---

## ✨ 주요 기능 (Features)

| 기능                    | 설명                                      |
| --------------------- | --------------------------------------- |
| **🎬 편리한 영상 재생**      | 강의 영상을 부드럽게 재생하고 필요 시 전체화면으로 전환할 수 있어요. |
| **🔖 중요한 순간 ‘클립’ 저장** | 기억하고 싶은 구간을 클립으로 저장해 두고 언제든 다시 볼 수 있어요. |
| **📝 클립 메모 작성**       | 클립마다 메모를 추가해 학습 포인트를 기록해둘 수 있어요.        |
| **🌐 언어 선택 & 검색**     | 언어별 필터와 검색 기능으로 원하는 영상을 빠르게 찾을 수 있어요.   |
| **🖼️ 썸네일 기반 영상 목록**  | 썸네일과 제목으로 구성된 UI로 영상을 쉽게 탐색할 수 있어요.     |


---


## 🧰 기술스택(Tech Stack)
| 구분           | 상세 내용                                                         |
| ------------ | ------------------------------------------------------------- |
| **프레임워크**    | UIKit / AVFoundation / AVKit / CoreData                       |
| **라이브러리**    | DropDown                                                      |
| **개발 도구**    | Xcode / SwiftLint / Git / GitHub / GitKraken                  |
| **UI/UX 지원** | iPhone 세로 지원, iPad 가로·세로 지원, Light/Dark Mode 대응, 커스텀 영상 재생 UI |


---


📂 프로젝트 구조 (Project Structure)

iOS5team2MainboardUiKitProject
├── AppDelegate.swift
├── SceneDelegate.swift
├── Views/
│ └── MainLayout.swift
├── Controllers/
│ ├── MainViewController.swift
│ ├── MainViewController+Actions.swift
│ ├── MainViewController+CollectionView.swift
│ ├── MainViewController+Search.swift
│ └── ...
├── Managers/
│ ├── VideoPlayerManager.swift
│ ├── ThumnailManager.swift
│ └── WeightStore.swift
├── Models/
│ ├── VideoEntity
│ └── ClipEntity
└── Resources/
├── Assets.xcassets
└── LaunchScreen



## 🖥️ 화면 소개 (Screen Preview)

<table>
  <tr>
    <th align="center">메인 화면</th>
    <th align="center">클립 화면</th>
  </tr>
  <tr>
    <td align="center">
      <img src="https://private-user-images.githubusercontent.com/235646571/515219501-350bdafa-36ca-4995-9034-57a86c8b8eb4.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NjMzOTA3MDUsIm5iZiI6MTc2MzM5MDQwNSwicGF0aCI6Ii8yMzU2NDY1NzEvNTE1MjE5NTAxLTM1MGJkYWZhLTM2Y2EtNDk5NS05MDM0LTU3YTg2YzhiOGViNC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUxMTE3JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MTExN1QxNDQwMDVaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0xODYzNmVhNzk0MjM4MWIwNzkxYTQ3MmQ5N2Q5ODVjMDMzYzczMTIyNTZkOWFmNmNhZTI2NWRmMzUzOGM5OWZlJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.bOcoL5dWF6uPnsTjDsI_RJKHyUuwhTxRjYpUuGDIaZs" width="250">
    </td>
    <td align="center">
      <img src="https://private-user-images.githubusercontent.com/235646571/515219501-350bdafa-36ca-4995-9034-57a86c8b8eb4.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NjMzOTA3MDUsIm5iZiI6MTc2MzM5MDQwNSwicGF0aCI6Ii8yMzU2NDY1NzEvNTE1MjE5NTAxLTM1MGJkYWZhLTM2Y2EtNDk5NS05MDM0LTU3YTg2YzhiOGViNC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUxMTE3JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MTExN1QxNDQwMDVaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0xODYzNmVhNzk0MjM4MWIwNzkxYTQ3MmQ5N2Q5ODVjMDMzYzczMTIyNTZkOWFmNmNhZTI2NWRmMzUzOGM5OWZlJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.bOcoL5dWF6uPnsTjDsI_RJKHyUuwhTxRjYpUuGDIaZs" width="250">
    </td>
  </tr>
  <tr>
    <td align="center">영상 목록 · 언어 선택 · 검색 기능</td>
    <td align="center">클립 저장 · 재생 · 메모 작성</td>
  </tr>
</table>




---


## 🤝 협업

* **기능 담당 방식으로 개발**
  * 팀원 각자가 맡은 기능(영상 재생, CoreData, DropDown, UI 등)을 기준으로 브랜치를 만들어 작업했습니다.
  * 작업이 어느 정도 마무리되면 main 브랜치에 병합하는 방식으로 진행했습니다.

* **Freeform을 활용한 화면 설계**
  * 화면 구조나 UI 흐름이 필요한 경우 Freeform을 이용해 함께 보면서 조율했습니다.
  * 기능 간 연결이 필요한 부분은 즉시 논의하며 해결했습니다.

* **병합 전 간단한 검토 진행**
  * 브랜치를 합치기 전에 동작 여부, 충돌 여부, 레이아웃 문제 등을 서로 확인했습니다.

* **필요한 규칙만 공유**
  * SwiftLint 등 기본적인 규칙만 맞춰두고,
  * 그 외의 코딩 스타일이나 파일 구성은 각자의 방식대로 진행했습니다.
  * 최종 단계에서 전체 구조를 함께 정리하며 마무리했습니다.


---



##  팀원 소개

| | | | | |
|:---:|:---:|:---:|:---:|:---:|
| <img width="200" height="200" alt="image" src="https://avatars.githubusercontent.com/u/235646788?v=4" alt="김대현" /> | <img width="200" height="200" alt="image" src="https://avatars.githubusercontent.com/u/235645278?v=4" alt="김태윤" /> | <img width="200" height="200" alt="image" src="https://avatars.githubusercontent.com/u/235646562?v=4" alt="김찬영"/> | <img width="200" height="200" alt="image" src="https://avatars.githubusercontent.com/u/235646533?v=4" alt="여승위"/> | <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/e2bfd524-b4ed-4ecf-9656-7e133cad6f6f" alt="천용휘" /> |
| **iOS** | **iOS** | **iOS** | **iOS** | **iOS** |
| **[김대현](https://github.com/Lala-roid)**<br> | **[김태윤](https://github.com/oscar701174)**<br> | **[김찬영](https://github.com/cymoseskim)**<br> | **[여승위](https://github.com/yeobare-blip)**<br> | **[천용휘](https://github.com/CheonYH)**<br> |
|  | |  |  |   |
