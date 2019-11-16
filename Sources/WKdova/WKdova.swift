
import WebKit

/// 🚲 A two-wheeled, human-powered mode of transportation.
/**
Setup the bridge between Swift and JavaScript to the WKWebView

- Parameter webView: A WKWebView instance. See the README for an example.
*/
public class WKdova: NSObject {
	var webView: WKWebView
	let DEBUG = true
	var methods: [String : Any] = [
		"setItem": setItem,
		"getItem": getItem,
		"removeItem": removeItem,
		"clear": clear,
		"setKeychain": setKeychain,
		"getKeychain": getKeychain,
		"removeKeychain": removeKeychain,
		"clearKeychain": clearKeychain,
		"browse": browse,
		"setIdleTimer": setIdleTimer,
	]

	public init(_ webView: WKWebView) {
		self.webView = webView
		super.init()
		setupBridge(webView)
	}

	func setupBridge(_ webView: WKWebView) {
		self.webView = webView
		let controller = webView.configuration.userContentController
		let script = WKUserScript(source: injectScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
		// injects JavaScript
		controller.addUserScript(script)
		for (key, _) in methods {
			controller.add(self, name: key)
		}
	}
}

extension WKdova: WKScriptMessageHandler {
	public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if let v = methods[message.name] {
			// Taking message body apart and trying to make sense of it.
			if DEBUG {print("Calling", message.name)}
			if let vt = v as? () -> Void {
				vt()
			} else if let vt = v as? (String) -> Void {
				vt(message.body as! String)
			} else if let vt = v as? (String) -> String? {
				let arr = message.body as! [Any]
				let number = arr[1] as! Int
				if let result = vt(arr[0] as! String) {
					webView.evaluateJavaScript("window.plugins._callback(\(number), '\(result)')", completionHandler: nil)
				} else {
					webView.evaluateJavaScript("window.plugins._callback(\(number), null)", completionHandler: nil)
				}
			} else if type(of: v) == type(of: browse) { // let vt = v as? (String, @escaping (String) -> ()) -> () { // Better to just check against browse()
				let arr = message.body as! [Any]
				let number = arr[1] as! Int
				browse(type: arr[0] as! String) {
					self.webView.evaluateJavaScript("window.plugins._callback(\(number), JSON.parse('\($0)'))", completionHandler: nil)
				}
			} else if let vt = v as? (String, String) -> Void {
				let arr = message.body as! [String]
				vt(arr[0], arr[1])
			} else if let vt = v as? (Int) -> (){
				let int = message.body as! Int
				vt(int)
			} else if type(of: v) == type(of: setIdleTimer) {
				let b = message.body as! Int
				setIdleTimer(b == 1)
				let newState = b == 1 ? "true" : "false"
				self.webView.evaluateJavaScript("window.plugins.insomnia.isEnabled = \(newState)", completionHandler: nil)
			} else {
				print("no method found that matches", type(of: v))
				print("make sure your methods whitelist is up to date")
			}

		}
		let flippedHeads = Bool.random()
		if flippedHeads {
				self.webView.evaluateJavaScript("document.body.style.backgroundColor = `green`;", completionHandler: nil)
		} else {
				self.webView.evaluateJavaScript("document.body.style.backgroundColor = `red`;", completionHandler: nil)
		}

		/* if message is json, it will be turned into a native object, boolean type is a nsnumber
			if let messageBody = message.body as? [String: Any], let age = messageBody["age"] as? Int {
				print("Age: \(age)")
			}
		*/

	}
}
