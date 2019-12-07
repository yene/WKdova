// Camera.swift

import UIKit

open class ImagePicker: NSObject {
	private let pickerController: UIImagePickerController
	private weak var presentationController: UIViewController?
	private var delegate: ((UIImage?) -> Void)!
	
	public init(presentationController: UIViewController) {
		self.pickerController = UIImagePickerController()
		super.init()
		self.presentationController = presentationController
		self.pickerController.delegate = self
		self.pickerController.allowsEditing = false
		self.pickerController.mediaTypes = ["public.image"]
	}
	
	private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
		guard UIImagePickerController.isSourceTypeAvailable(type) else {
			// TODO: inform user of missing permissions, or that camera is missing
			return nil
		}
		return UIAlertAction(title: title, style: .default) { [unowned self] _ in
			self.pickerController.sourceType = type
			self.presentationController?.present(self.pickerController, animated: true)
		}
	}
	
	public func present(from sourceView: UIView, cb: @escaping (UIImage?) -> Void) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		if let action = self.action(for: .camera, title: "Take Picture") {
			alertController.addAction(action)
		}
		/*
		if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
			alertController.addAction(action)
		}*/
		if let action = self.action(for: .photoLibrary, title: "From Library") {
			alertController.addAction(action)
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		if UIDevice.current.userInterfaceIdiom == .pad {
			alertController.popoverPresentationController?.sourceView = sourceView
			alertController.popoverPresentationController?.sourceRect = sourceView.bounds
			alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
		}
		self.delegate = cb
		self.presentationController?.present(alertController, animated: true)
	}
	private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
		controller.dismiss(animated: true, completion: nil)
		self.delegate(image)
	}
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.pickerController(picker, didSelect: nil)
	}
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let image = info[.originalImage] as? UIImage else {
			return self.pickerController(picker, didSelect: nil)
		}
		self.pickerController(picker, didSelect: image)
	}
}


func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
	let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
	UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
	image.draw(in: rect)
	let newImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return newImage!
}
