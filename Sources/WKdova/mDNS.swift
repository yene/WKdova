// mDNS.swift
import Foundation

struct Service: Codable {
	var name: String
	var hostname: String
	var port: Int
	var address: String // ipv4 address
	var txtRecord: [String:String]?
}

var result = ""
let DEBUG = false

// Browse scans for 6 seconds and then returns the found devices as JSON.
// params type "_ssh._tcp"
public func browse(type: String, cb: @escaping (String) -> Void) {
	DispatchQueue.global(qos: .background).async {
		let agent = BrowserAgent()
		let browser = NetServiceBrowser()
		browser.delegate = agent
		browser.stop()
		browser.schedule(in: RunLoop.current, forMode: .default)
		browser.searchForServices(ofType: type, inDomain: "")
		RunLoop.current.run()
		DispatchQueue.main.async {
			cb(result)
		}
	}
}

class BrowserAgent: NSObject, NetServiceBrowserDelegate {
	var netServices: [NetService] = []
	var timer: Timer? = nil

	func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
		if DEBUG { print("Resolve error:", sender, errorDict) }
	}
	func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
		if DEBUG { print("Search started") }
		startTimer(browser)
	}
	func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
		if DEBUG { print("Search stopped") }
		self.finish(browser)
	}
	func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
		if DEBUG {print("service found: \(service.name)") }
		netServices.append(service)
		service.resolve(withTimeout: 5)
		if !moreComing {
			if DEBUG { print("Got services, waiting for all to finish resolve", netServices.count) }
			startTimer(browser)
		}
	}
	
	func startTimer(_ browser: NetServiceBrowser) {
		if let t = self.timer {
			t.invalidate()
		}
		if DEBUG { print("starting timer for 6s") }
		self.timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { _ in
			browser.stop()
		}
	}
	
	func finish(_ browser: NetServiceBrowser) {
		var services: [Service] = []
		for ns in netServices {
			guard let hostName = ns.hostName else {
				continue
			}
			let host = removeTrailingDot(hostName) // Note: this is not neccessary but we do it anyway.
			guard let ip = resolveIPv4(ns.addresses!) else {
				continue
			}
			var s = Service(name: ns.name, hostname: host, port: ns.port, address: ip, txtRecord: nil)
			if let data = ns.txtRecordData() {
				let dict = NetService.dictionary(fromTXTRecord: data)
				let dictValues: [String:String] = dict.mapValues {
					if let s = String(data: $0, encoding: .utf8) {
						return s
					}
					return ""
				}
				s.txtRecord = dictValues
			}
			services.append(s)
		}
		let jsonData = try! JSONEncoder().encode(services)
		let jsonString = String(data: jsonData, encoding: .utf8)!
		result = jsonString
		browser.stop()
	}
}

func removeTrailingDot(_ s: String) -> String {
	if s.last == "." {
		return String(s.dropLast())
	}
	return s
}

// Find an IPv4 address from the service address data
func resolveIPv4(_ addresses: [Data]) -> String? {
	var result: String?
	
	for addr in addresses {
		let data = addr as NSData
		var storage = sockaddr_storage()
		data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
		if Int32(storage.ss_family) == AF_INET {
			let addr4 = withUnsafePointer(to: &storage) {
				$0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
					$0.pointee
				}
			}
			if let ip = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii) {
				result = ip
				break
			}
		}
	}
	return result
}
