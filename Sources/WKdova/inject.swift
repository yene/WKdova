// inject.swift


// Swift Packages don't support including assets

let deviceJSON = device()


// TODO: don't grow callbacks forever
let injectScript = """
function callWebKit(handler, message) {
	return function() {
		try {
			console.log(handler, message);
			webkit.messageHandlers[handler].postMessage(message);
		} catch(e) {
			console.log('Failed when trying to call webkit handler.', e);
		}
	}
}

function parseDevice() {
	return JSON.parse('\(deviceJSON)')
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
		clear: callWebKit('clear'),
	},
	device: parseDevice(),
}

window.plugins._callback = function(number, value) {
	callbacks[number](value);
}

"""
