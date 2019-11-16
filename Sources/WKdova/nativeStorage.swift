// nativeStorage.swift
import Foundation

// Add key and value to nativeStorage
func setItem(key: String, value: String) {
	storageSuit().set(value, forKey: key)
}

// Retrieve a value by the key from nativeStorage
// returns null if not found
func getItem(key: String) -> String? {
	return storageSuit().string(forKey: key)
}

// Remove an item by key from nativeStorage
func removeItem(key: String) {
	storageSuit().removeObject(forKey: key)
}

// Clear nativeStorage
func clear() {
	UserDefaults.standard.removePersistentDomain(forName: "nativeStorage")
}

func storageSuit() -> UserDefaults {
	return UserDefaults(suiteName: "nativeStorage")!
}
