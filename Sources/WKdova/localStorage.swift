// localStorage.swift
import Foundation

// Add key and value to localStorage
// 0: key, 1: value
func setItem(key: String, value: String) {
	print("setitem", key, value)
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

// Clear all localStorage
func clear() {
	UserDefaults.standard.removePersistentDomain(forName: "localStorage")
}

func storageSuit() -> UserDefaults {
	return UserDefaults(suiteName: "localStorage")!
}
