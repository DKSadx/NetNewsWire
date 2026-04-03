//
//  MainFeedCollectionViewCell.swift
//  NetNewsWire-iOS
//
//  Created by Stuart Breckenridge on 23/06/2025.
//  Copyright © 2025 Ranchero Software. All rights reserved.
//

import UIKit
import RSCore
import Account
import RSTree

final class MainFeedCollectionViewCell: UICollectionViewCell {
	@IBOutlet var feedTitle: UILabel!
	@IBOutlet var faviconView: IconView!
	@IBOutlet var unreadCountLabel: UILabel!
	private var faviconLeadingConstraint: NSLayoutConstraint?

	var iconImage: IconImage? {
		didSet {
			faviconView.iconImage = iconImage
			if let preferredColor = iconImage?.preferredColor {
				faviconView.tintColor = UIColor(cgColor: preferredColor)
			} else {
				faviconView.tintColor = Assets.Colors.secondaryAccent
			}
		}
	}

	private var _unreadCount: Int = 0

	var unreadCount: Int {
		get {
			return _unreadCount
		}
		set {
			_unreadCount = newValue
			if newValue == 0 {
				unreadCountLabel.isHidden = true
			} else {
				unreadCountLabel.isHidden = false
			}
			unreadCountLabel.text = newValue.formatted()
		}
	}

	var isMuted = false {
		didSet {
			mutedImageView.isHidden = !isMuted
		}
	}

	private let mutedImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "speaker.slash"))
		imageView.tintColor = .secondaryLabel
		imageView.contentMode = .scaleAspectFit
		imageView.isHidden = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	/// If the feed is contained in a folder, the indentation level is 1
	/// and the cell's favicon leading constrain is increased. Otherwise,
	/// it has the standard leading constraint.
	///
	/// On the storyboard, no leading constraint is set.
	var indentationLevel: Int = 0 {
		didSet {
			if indentationLevel == 1 {
				faviconLeadingConstraint?.constant = 32
			} else {
				faviconLeadingConstraint?.constant = 16
			}
		}
	}

	override var accessibilityLabel: String? {
		get {
			let name = feedTitle.text ?? ""
			if isMuted {
				let mutedLabel = NSLocalizedString("muted", comment: "Muted label for accessibility")
				return "\(name) \(mutedLabel)"
			} else if unreadCount > 0 {
				let unreadLabel = NSLocalizedString("unread", comment: "Unread label for accessibility")
				return "\(name) \(unreadCount) \(unreadLabel)"
			} else {
				return name
			}
		}
		set {}
	}

    override func awakeFromNib() {
		MainActor.assumeIsolated {
			super.awakeFromNib()
			isAccessibilityElement = true
			feedTitle.isAccessibilityElement = false
			unreadCountLabel.isAccessibilityElement = false
			faviconView.isAccessibilityElement = false
			faviconLeadingConstraint = faviconView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor)
			faviconLeadingConstraint?.isActive = true

			contentView.addSubview(mutedImageView)
			NSLayoutConstraint.activate([
				mutedImageView.centerYAnchor.constraint(equalTo: unreadCountLabel.centerYAnchor),
				mutedImageView.trailingAnchor.constraint(equalTo: unreadCountLabel.trailingAnchor),
				mutedImageView.widthAnchor.constraint(equalToConstant: 14),
				mutedImageView.heightAnchor.constraint(equalToConstant: 14)
			])
		}
    }

	override func updateConfiguration(using state: UICellConfigurationState) {
		var backgroundConfig: UIBackgroundConfiguration
		if #available(iOS 18, *) {
			backgroundConfig = UIBackgroundConfiguration.listCell().updated(for: state)
		} else if traitCollection.userInterfaceIdiom == .pad {
			backgroundConfig = UIBackgroundConfiguration.listSidebarCell().updated(for: state)
		} else {
			backgroundConfig = UIBackgroundConfiguration.listGroupedCell().updated(for: state)
		}

		switch (state.isHighlighted || state.isSelected || state.isFocused, traitCollection.userInterfaceIdiom) {
		case (true, .pad):
			backgroundConfig.backgroundColor = .tertiarySystemFill
			feedTitle.textColor = Assets.Colors.primaryAccent
			feedTitle.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize,
											   weight: .semibold)
			unreadCountLabel.textColor = Assets.Colors.primaryAccent
			unreadCountLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
			mutedImageView.tintColor = Assets.Colors.primaryAccent
		case (true, .phone):
			backgroundConfig.backgroundColor = Assets.Colors.primaryAccent
			feedTitle.textColor = .white
			unreadCountLabel.textColor = .white
			mutedImageView.tintColor = .white
			if feedTitle.text == "All Unread" {
				faviconView.tintColor = .white
			}
		default:
			feedTitle.textColor = .label
			feedTitle.font = UIFont.preferredFont(forTextStyle: .body)
			unreadCountLabel.font = UIFont.preferredFont(forTextStyle: .body)
			unreadCountLabel.textColor = .secondaryLabel
			mutedImageView.tintColor = .secondaryLabel
			if traitCollection.userInterfaceIdiom == .phone {
				if feedTitle.text == "All Unread" {
					if let preferredColor = iconImage?.preferredColor {
						faviconView.tintColor = UIColor(cgColor: preferredColor)
					} else {
						faviconView.tintColor = Assets.Colors.secondaryAccent
					}
				}
			}
		}
		self.backgroundConfiguration = backgroundConfig
	}
}
