
import WebKit

public class WKdova: NSObject {
	var webView: WKWebView
	let DEBUG = true
	var methods: [String : Any] = [
		"keepAwake": keepAwake,
		"allowSleepAgain": allowSleepAgain,
		"setItem": setItem,
		"getItem": getItem,
		"clear": clear,
	]


	public init(_ webView: WKWebView) {
		self.webView = webView
		super.init()
		setupBridge(webView)
	}

	/** @abstract Setup the bridge between Swift and JavaScript to the WKWebView
	@param controller A WKUserContentController instance which is setup with WKWebViewConfiguration and WKWebView. See the README for an example.
	*/
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
			}
			if let vt = v as? (String) -> Void {
				vt(message.body as! String)
			}
			if let vt = v as? (String) -> String? {
				let arr = message.body as! [Any]
				let number = arr[1] as! Int
				if let result = vt(arr[0] as! String) {
					webView.evaluateJavaScript("window.plugins._callback(\(number), '\(result)')", completionHandler: nil)
				} else {
					webView.evaluateJavaScript("window.plugins._callback(\(number), null)", completionHandler: nil)
				}

			}
			if let vt = v as? (String, String) -> Void {
				let arr = message.body as! [String]
				vt(arr[0], arr[1])
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
