// localStorage.swift
import Foundation

// Add key and value to localStorage
func setItem(key: String, value: String) {
	storageSuit().set(value, forKey: key)
}

// Retrieve a value by the key from localStorage
// returns null if not found
func getItem(key: String) -> String? {
	return storageSuit().string(forKey: key)
}

// Remove an item by key from localStorage
func removeItem(key: String) {
	storageSuit().removeObject(forKey: key)
}

// Clear localStorage
func clear() {
	UserDefaults.standard.removePersistentDomain(forName: "localStorage")
}

func storageSuit() -> UserDefaults {
	return UserDefaults(suiteName: "localStorage")!
}
