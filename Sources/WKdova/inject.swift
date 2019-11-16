// inject.swift


// Swift Packages don't support including assets

let deviceJSON = device()
let appJSON = app()

// TODO: don't grow callbacks forever
let injectScript = """
function callWebKit(handler, message) {
	return function() {
		try {
			console.log(handler, message);
			webkit.messageHandlers[handler].postMessage(message);
		} catch(e) {
			console.log('Failed when trying to call webkit handler. Probably forgot to add to methods:', handler);
			console.log(e);
		}
	}
}

var callbacks = [];

window.plugins = {
	insomnia: {
		keepAwake: callWebKit('keepAwake'),
		allowSleepAgain: callWebKit('allowSleepAgain'),
	},
	localStorage: {
		setItem: (key, value) => {
			console.log(key, value);
			callWebKit('setItem', [key, value])()
		},
		getItem: (key, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('getItem', [key, callbackPosition-1])()
		},
		removeItem: (key) => {
			callWebKit('removeItem', key)()
		},
		clear: callWebKit('clear'),
	},
	keychain: {
		setItem: (key, value) => {
			console.log(key, value);
			callWebKit('setKeychain', [key, value])()
		},
		getItem: (key, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('getKeychain', [key, callbackPosition-1])()
		},
		removeItem: (key) => {
			callWebKit('removeKeychain', key)()
		},
		clear: callWebKit('clearKeychain'),
	},
	mDNS: {
		browse: (type, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('browse', [type, callbackPosition-1])()
		},
	},
	device: JSON.parse('\(deviceJSON)'),
	app: JSON.parse('\(appJSON)'),
}

window.plugins._callback = function(number, value) {
	console.log('got callback value', value);
	callbacks[number](value);
	delete callbacks[number];
}

"""
