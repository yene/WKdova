// Insomnia.swift

import UIKit

func keepAwake() {
	UIApplication.shared.isIdleTimerDisabled = true
}

func allowSleepAgain() {
	UIApplication.shared.isIdleTimerDisabled = false
}
