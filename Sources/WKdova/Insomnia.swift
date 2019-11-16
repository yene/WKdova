// Insomnia.swift

import UIKit

func isIdleTimerDisabled() -> Bool {
	let should = UserDefaults.standard.bool(forKey: "isIdleTimerDisabled")
	UIApplication.shared.isIdleTimerDisabled = should
	return should
}

func setIdleTimer(_ b: Bool) {
	UserDefaults.standard.set(b, forKey: "isIdleTimerDisabled")
	UIApplication.shared.isIdleTimerDisabled = b
}

