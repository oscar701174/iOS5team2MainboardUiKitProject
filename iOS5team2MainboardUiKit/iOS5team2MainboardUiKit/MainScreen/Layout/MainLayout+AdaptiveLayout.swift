//
//  MainLayout+Layout.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit

extension MainLayout {

    func updateForIpad(for trait: UITraitCollection, containerSize: CGSize? = nil) {

        let size = containerSize ?? bounds.size
        if trait.userInterfaceIdiom == .pad &&  size.width > size.height {
            NSLayoutConstraint.deactivate(headerDefaultConstriants)
            NSLayoutConstraint.deactivate(topVideoDefaultConstraints)
            NSLayoutConstraint.deactivate(progressSliderDefaultConstraints)
            NSLayoutConstraint.deactivate(videoButtonDefaultConstraints)
            NSLayoutConstraint.deactivate(videoCollectionDefaultConstraints)
            NSLayoutConstraint.deactivate(bottomMenuDefaultConstrains)

            NSLayoutConstraint.activate(headerIPadLandscapeConstriants)
            NSLayoutConstraint.activate(topVideoIPadLandscapeConstraints)
            NSLayoutConstraint.activate(progressSliderIPadLandscapeConstraints)
            NSLayoutConstraint.activate(videoButtonIPadLandscapeConstraints
            )
            NSLayoutConstraint.activate(videoCollectionIPadLandscapeConstraints)
            NSLayoutConstraint.activate(bottomMenuIPadLandscapeConstraints)

        } else {
            NSLayoutConstraint.deactivate(headerIPadLandscapeConstriants)
            NSLayoutConstraint.deactivate(topVideoIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(progressSliderIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(videoButtonIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(videoCollectionIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(bottomMenuIPadLandscapeConstraints)

            NSLayoutConstraint.activate(headerDefaultConstriants)
            NSLayoutConstraint.activate(topVideoDefaultConstraints)
            NSLayoutConstraint.activate(progressSliderDefaultConstraints)
            NSLayoutConstraint.activate(videoButtonDefaultConstraints)
            NSLayoutConstraint.activate(videoCollectionDefaultConstraints)
            NSLayoutConstraint.activate(bottomMenuDefaultConstrains)

        }
        layoutIfNeeded()
    }
}
