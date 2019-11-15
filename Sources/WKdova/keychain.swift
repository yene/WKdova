// keychain.swift

import Foundation

func setKeychain(key: String, value: String) {
	let keychain = KeychainSwift()
	keychain.set(key, forKey: value)
}

func getKeychain(key: String) -> String {
	let keychain = KeychainSwift()
	keychain.get(key)
}

// Remove single key
func removeKeychain(key: String) {
	let keychain = KeychainSwift()
	keychain.delete(key)
}

// Delete everything from app's Keychain.
func clearKeychain() {
	let keychain = KeychainSwift()
	keychain.clear()
}
