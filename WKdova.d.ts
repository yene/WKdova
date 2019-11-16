// WKdova.d.ts

export interface App {
	/** App name */
	name: string;
	/** App version */
	version: string;
	/** App build */
	build: string;
	/** App bundle ID */
  bundleid: string;
}

export interface Device {
	/** Device name */
	name: string;
	/** Readable model*/
	model: string;
	/** Model identifier */
	modelIdentifier: string;
	/** iOS Version */
	version: string;
	/** Platform is always iOS */
	platform: string;
	/** UUID, will change if device is uninstalled, see identifierForVendor for more */
	uuid: string;
	/** true if in Simulator */
	isVirtual: boolean;
}

interface StringMap { [key: string]: string; }

export interface Service {
	name: string;
	hostname: string;
	port: number;
  txtRecord: StringMap;
}

declare global {
	interface Window {
		plugins: {
			test: Service,
			insomnia: {
				/**
				 * If set to true the screen is prevented from turning off.
				 * You should set this property only if necessary and should be sure to reset it to false when the need no longer exists.
				 */
				isEnabled: boolean,
				/**
				 * setEnabled allows you to prevent the display from turning off.
				 *
				 * Warning! This setting is persisted.
				 */
				setEnabled: (state: boolean) => void,
			},
			nativeStorage: {
				setItem: (key: string, value: string) => void,
				getItem: (key: string, cb: (string) => void) => void,
				removeItem: (key: string) => void,
				clear: () => void,
			},
			keychain: {
				setItem: (key: string, value: string) => void,
				getItem: (key: string, cb: (string) => void) => void,
				removeItem: (key: string) => void,
				clear: () => void,
			},
			mDNS: {
				/** Searches for 6 seconds, then calls `cb` with the results. */
				browse: (type: string, cb: ([Service]) => void) => void,
			},
			device: Device,
			app: App,
		};

	}
}
