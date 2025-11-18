<p align="center">
   <img src="./ReadMeImage/IntroImage.png" width="260"> 
</p>

<br>

<h1 align="center">Cling</h1>

<p align="center">
  <b>Clip + Learning = Cling</b><br>
  <b>강의 속 핵심 순간을 빠르게 저장하고 학습 효율을 극대화하는 영상 플레이어</b>
</p>

<br>

## 📱 프로젝트 개요 (Overview)

**Cling은 강의 영상을 학습 목적에 맞게 더 효과적으로 탐색하고, 필요한 구간을 ‘클립(Clip)’으로 저장해 복습할 수 있도록 설계된 UIKit 기반 영상 플레이어입니다.**  
언어 선택, 검색, 15초 이동, 전체화면 등 강의 시청에 필요한 기능은 물론,  
중요한 학습 포인트를 클립 단위로 저장하고 기록해 두는 데 최적화되어 있습니다.

> **"Clip the moment, Learn with Cling."**  
> **필요한 순간을 붙잡아(Cling) 학습으로 연결하는 플레이어.**

Cling은 사용자가 강의 영상에서 원하는 부분을 즉시 찾고,  
그 순간을 놓치지 않도록 저장하여 학습 효율을 높이는 데 집중합니다.



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


## 📂 프로젝트 구조 (Project Structure)

```
iOS5team2MainboardUiKitProject
├── BottomMenu/
│   ├── SettingViewController.swift
│   └── TagViewController.swift
│
├── ClipLibrary/
│   └── ClipPlayerViewControllerParts/
│       ├── MyScrollableContainer.swift
│       ├── ClipPlayerViewController.swift
│       ├── ClipPlayerViewControllerExtension.swift
│       └── MyVideoListViewController.swift
│
├── ClipPlayer/
│   ├── ClipPlayer.swift
│   └── MyClipModel.swift
│
├── Common/
│   ├── Colors.swift
│   ├── Languages.swift
│   ├── ThumbnailManager.swift
│   ├── TimeFormatter.swift
│   └── UIImage+Resize.swift
│
├── Intro/
│   ├── IntroModel.swift
│   └── IntroPageViewController.swift
│
├── MainScreen/
│   ├── Controller/
│   │   ├── MainViewController.swift
│   │   ├── MainViewController+Actions.swift
│   │   ├── MainViewController+CollectionView.swift
│   │   └── MainViewController+Search.swift
│   │
│   ├── Layout/
│   │   ├── MainLayout.swift
│   │   ├── MainLayout+AdaptiveLayout.swift
│   │   ├── MainLayout+BottomArea.swift
│   │   ├── MainLayout+Header.swift
│   │   ├── MainLayout+VideoCollection.swift
│   │   └── MainLayout+VideoPlayer.swift
│   │
│   ├── Manager/
│   │   └── VideoPlayerManager.swift
│   │
│   └── View/
│       ├── PlayerView.swift
│       └── VideoCell.swift
│
├── Model/
│   ├── Entities/
│   │   ├── VideoEntity.swift
│   │   └── ClipEntity.swift
│   │
│   └── Managers/
│       ├── VideoManager.swift
│       ├── ClipManager.swift
│       └── WeightStore.swift
│
└── SplashScreen/
    └── SplashViewController.swift
```

---

## 🖥️ 화면 소개 (Screen Preview)


| 관심분야 설정 화면 | 메인 화면 | 클립 화면 | 커스텀 태그 추가 화면 | 설정 화면 |
| :---------------: | :-------: | :-------: | :-------------------: | :-------: |
| <img src="./ReadMeImage/Interest.png" width="260"> | <img src="./ReadMeImage/Main.png" width="260"> | <img src="./ReadMeImage/Clip.png" width="260"> | <img src="./ReadMeImage/CustomTag.png" width="260"> | <img src="./ReadMeImage/Setting.png" width="260"> |




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
| 개발 / 기획 | 개발 / 기획 | 개발 / 회의록 작성 | 개발 / 디자인 | 개발 / 데이터 관리 |
