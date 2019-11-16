# WKdova

A Swift Package which offers WKWebview turnkey solutions for common tasks. Think of it as a light weight Cordova.

- [x] Insomania: Prevent display falling asleep.
- [x] NativeStorage: Persistent key/value storage, which will not be cleared by the OS.
- [x] Keychain: Store strings in the Keychain.
- [x] Device information
- [x] mDNS (Bonjour)
- [ ] Global native dialogs
- [ ] Push notification
- [ ] network information
- [ ] GPS location

## How to use

Setup a WKWebview

```swift
import WebKit

override func viewDidLoad() {
	super.viewDidLoad()
	let webView = WKWebView(frame: .zero)
	view.addSubview(webView)
	webView.translatesAutoresizingMaskIntoConstraints = false
	webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
	webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
	webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	webView.scrollView.bounces = false;
	webView.isOpaque = false;
	if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "") {
		webView.load(URLRequest(url: url))
	}
	WKdova(webView)
}
```


Import WKdova package and pass it the webview.

```swift
import WKdova

...
WKdova(webView)
```

You are now ready to call JavaScript over global window object.

```js
if (window.plugins === undefined) {
	// handle if plugin not loaded
}

// insomnia
window.plugins.insomnia.setEnabled(true);
window.plugins.insomnia.isEnabled;

// nativeStorage
window.plugins.nativeStorage.setItem('key', 'value');
window.plugins.nativeStorage.getItem('key', console.log);
window.plugins.nativeStorage.removeItem('key');
window.plugins.nativeStorage.clear();

// keychain
window.plugins.keychain.setItem('key', 'secret');
window.plugins.keychain.getItem('key');
window.plugins.keychain.removeItem('key')
window.plugins.keychain.clear();

// mDNS (will search for 6 seconds)
window.plugins.mDNS.browse('_http._tcp', console.log);
```

## TypeScript definition
Copy TypeScript definition file `WKdova.d.ts` to get the type support and juicy autocomplete.
