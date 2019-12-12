// device.swift

import UIKit

struct Device: Codable {
	var name: String
	var model: String // iPad2,5; iPhone 5 is iPhone 5,1. See http://theiphonewiki.com/wiki/index.php?title=Models
	var modelIdentifier: String
	var platform: String // iOS
	var uuid: String // identifierForVendor
	var isVirtual: Bool // is running in simulator
	var version: String
	var language: String
	var region: String
}

func device() -> String {
	let device = Device(
		name: UIDevice.current.name,
		model: UIDevice.modelName,
		modelIdentifier: UIDevice.modelIdentifier,
		platform: "iOS",
		uuid: UIDevice.current.identifierForVendor!.uuidString,
		isVirtual: isSimulator(),
		version: UIDevice.current.systemVersion,
		language: Locale.preferredLanguages.first!,
		region: NSLocale.current.regionCode! // This value is nil if you don't set the simulators language manually...
	)
	let jsonData = try! JSONEncoder().encode(device)
	let jsonString = String(data: jsonData, encoding: .utf8)!
	return jsonString
}

struct App: Codable {
	var name: String
	var version: String
	var build: String
	var bundleid: String
}

func app() -> String {
	let infoDict = Bundle.main.infoDictionary!
	let CFBundleName = infoDict["CFBundleName"] as! String
	let appName = infoDict["CFBundleDisplayName"] as? String ?? CFBundleName
	
	let app = App(
		name: appName,
		version: infoDict["CFBundleShortVersionString"] as! String,
		build: infoDict["CFBundleVersion"] as! String,
		bundleid: Bundle.main.bundleIdentifier!
	)
	
	let jsonData = try! JSONEncoder().encode(app)
	let jsonString = String(data: jsonData, encoding: .utf8)!
	return jsonString
}

// Checks if the current device that runs the app is xCode's simulator
func isSimulator() -> Bool {
	#if targetEnvironment(simulator)
	return true
	#else
	return false
	#endif
}
