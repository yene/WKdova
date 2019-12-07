// utils.swift

import UIKit

// openURL tries to launch the app associated with the URL, does nothing if it fails.
func openURL(u: String) {
	guard let url = URL(string: u) else {
		return
	}
	if UIApplication.shared.canOpenURL(url) {
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
}
