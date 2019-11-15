// Insomnia.swift

import UIKit

/*
<button onclick="window.plugins.insomnia.keepAwake()">keep awake</button>
<button onclick="window.plugins.insomnia.allowSleepAgain()">allow sleep again</button>
*/

func keepAwake() {
	UIApplication.shared.isIdleTimerDisabled = true
}

func allowSleepAgain() {
	UIApplication.shared.isIdleTimerDisabled = false
}
