// inject.swift

func injectScript() -> String {
	let deviceJSON = device()
	let appJSON = app()
	let timerDisabled = isIdleTimerDisabled() ? "true" : "false"
	let nt = Reachability.getNetworkType().trackingId
	
	// TODO: don't grow callbacks forever
	return """
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
	connection: {
		type: '\(nt)',
		getType: (func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('getNetworkType', callbackPosition-1)();
		}
	},
	geolocation: {
		getCurrentPosition: (func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('getCurrentPosition', callbackPosition-1)();
		},
	},
	camera: {
		pickImage: (maxWidth, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('pickImage', [maxWidth, callbackPosition-1])();
		},
	},
	insomnia: {
		isEnabled: \(timerDisabled),
		setEnabled: (state) => {
			callWebKit('setIdleTimer', state)();
		}
	},
	nativeStorage: {
		setItem: (key, value) => {
			console.log(key, value);
			callWebKit('setItem', [key, value])()
		},
		getItem: (key, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('getItem', [key, callbackPosition-1])();
		},
		removeItem: (key) => {
			callWebKit('removeItem', key)();
		},
		clear: callWebKit('clear'),
	},
	keychain: {
		setItem: (key, value) => {
			console.log(key, value);
			callWebKit('setKeychain', [key, value])();
		},
		getItem: (key, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('getKeychain', [key, callbackPosition-1])();
		},
		removeItem: (key) => {
			callWebKit('removeKeychain', key)();
		},
		clear: callWebKit('clearKeychain'),
	},
	mDNS: {
		browse: (type, func) => {
			var callbackPosition = callbacks.push(func);
			callWebKit('browse', [type, callbackPosition-1])();
		},
	},
	utils: {
		openURL: (url) => {
			callWebKit('openURL', url)();
		}
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
}
