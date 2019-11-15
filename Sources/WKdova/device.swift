// device.swift

import UIKit

struct Device: Codable {
	var name: String
	var model: String // iPad2,5; iPhone 5 is iPhone 5,1. See http://theiphonewiki.com/wiki/index.php?title=Models
	var modelIdentifier: String
	var platform: String // iOS
	var uuid: String // we generate a UUID for you and store it in standardUserDefaults, will disappear if uninstalled
	var isVirtual: Bool // is running in simulator
	var version: String
	var bundleid: String
}


func device() -> String {
	let device = Device(
		name: UIDevice.current.name,
		model: UIDevice.modelName,
		modelIdentifier: UIDevice.modelIdentifier,
		platform: "iOS",
		uuid: storedUUID(),
		isVirtual: isSimulator(),
		version: UIDevice.current.systemVersion,
		bundleid: Bundle.main.bundleIdentifier!
	)
	let jsonData = try! JSONEncoder().encode(device)
	let jsonString = String(data: jsonData, encoding: .utf8)!
	return jsonString
}

func storedUUID() -> String {
	if let uuid = UserDefaults.standard.string(forKey: "device-uuid") {
		return uuid
	}
	let uuid = UUID().uuidString
	UserDefaults.standard.set(uuid, forKey: "device-uuid")
	return uuid
}

/// Checks if the current device that runs the app is xCode's simulator
func isSimulator() -> Bool {
	#if targetEnvironment(simulator)
	return true
	#else
	return false
	#endif
}
