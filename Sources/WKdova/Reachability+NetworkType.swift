// Reachability+NetworkType.swift
// https://gist.github.com/speedoholic/1746ac93be8e26723ce4023f0f4d211a

//import Reachability //https://cocoapods.org/pods/ReachabilitySwift
import CoreTelephony

enum NetworkType {
	case unknown
	case noConnection
	case wifi
	case wwan2g
	case wwan3g
	case wwan4g
	case unknownTechnology(name: String)
	
	var trackingId: String {
		switch self {
		case .unknown:                      return "Unknown"
		case .noConnection:                 return "No Connection"
		case .wifi:                         return "Wifi"
		case .wwan2g:                       return "2G"
		case .wwan3g:                       return "3G"
		case .wwan4g:                       return "4G"
		case .unknownTechnology(let name):  return "Unknown Technology: \"\(name)\""
		}
	}
	
	var networkTypeInt: Int {
		switch self {
		case .unknown:                      return 9
		case .noConnection:                 return 9
		case .wifi:                         return 1
		case .wwan2g:                       return 2
		case .wwan3g:                       return 3
		case .wwan4g:                       return 4
		case .unknownTechnology:            return 9
		}
	}
}

extension Reachability {
	
	static func getNetworkType() -> NetworkType {
		guard let reachability: Reachability = try! Reachability() else { return .unknown }
		do {
			try reachability.startNotifier()
			switch reachability.connection {
				case .none: return .noConnection
				case .wifi: return .wifi
				case .cellular: return Reachability.getWWANNetworkType()
				case .unavailable: return .noConnection
			}
		} catch {
			return .unknown
		}
	}
	
	static func getWWANNetworkType() -> NetworkType {
		guard let currentRadioAccessTechnology = CTTelephonyNetworkInfo().currentRadioAccessTechnology else { return .unknown }
		switch currentRadioAccessTechnology {
		case CTRadioAccessTechnologyGPRS,
				 CTRadioAccessTechnologyEdge,
				 CTRadioAccessTechnologyCDMA1x:
			return .wwan2g
		case CTRadioAccessTechnologyWCDMA,
				 CTRadioAccessTechnologyHSDPA,
				 CTRadioAccessTechnologyHSUPA,
				 CTRadioAccessTechnologyCDMAEVDORev0,
				 CTRadioAccessTechnologyCDMAEVDORevA,
				 CTRadioAccessTechnologyCDMAEVDORevB,
				 CTRadioAccessTechnologyeHRPD:
			return .wwan3g
		case CTRadioAccessTechnologyLTE:
			return .wwan4g
		default:
			return .unknownTechnology(name: currentRadioAccessTechnology)
		}
	}
	
}
