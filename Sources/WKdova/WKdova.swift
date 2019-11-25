
import WebKit

public class WKdova: NSObject {
	var webView: WKWebView
	var imagePicker: ImagePicker!
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
		"pickImage": "pickImage",
		"getCurrentPosition": "getCurrentPosition",
	]
	
	public init(_ webView: WKWebView) {
		self.webView = webView
		super.init()
		setupBridge(webView)
		let viewController = UIApplication.shared.windows.first!.rootViewController
		self.imagePicker = ImagePicker(presentationController: viewController!)
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
			
			if message.name == "pickImage" {
				let arr = message.body as! [Any]
				let maxWidth = arr[0] as! CGFloat
				let number = arr[1] as! Int
				imagePicker.present(from: self.webView) {
					if var image = $0 {
						if image.size.width > maxWidth {
							image = resizeImage(image: image, width: maxWidth)
						}
						let jpg = image.jpegData(compressionQuality: 0.75)!
						let encodedData = jpg.base64EncodedString()
						self.webView.evaluateJavaScript("window.plugins._callback(\(number), '\(encodedData)')", completionHandler: nil)
					} else {
						self.webView.evaluateJavaScript("window.plugins._callback(\(number), null)", completionHandler: nil)
					}
				}
				return
			}
			
			if message.name == "getCurrentPosition" {
				let number = message.body as! Int
				let getLocation = GetLocation()
				getLocation.run {
					if let location = $0 {
						let s = "{coords:{latitude:\(location.coordinate.latitude), longitude:\(location.coordinate.longitude)}}"
						self.webView.evaluateJavaScript("window.plugins._callback(\(number), \(s))", completionHandler: nil)
					} else {
						self.webView.evaluateJavaScript("window.plugins._callback(\(number), null)", completionHandler: nil)
						print("Get Location failed \(getLocation.didFailWithError)")
					}
				}
				return
			}
			
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
	}
}

func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
	let ratio = width / image.size.width
	let newSize = CGSize(width: width, height: image.size.height * ratio)
	let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
	UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
	image.draw(in: rect)
	let newImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return newImage!
}
