//
//  SaveToPhotos.swift
//  RedditThing
//
//  Created by Ethan Chaffin on 6/13/26.
//

import UIKit
import Photos

public struct SaveToPhotos {
    /// - Warning: Do not use this without setting a Photo Library (Add Only) capability with a given reason!
    public static func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await requestAddOnlyAuthorization()

        try await PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        })
    }

    /// - Warning: Do not use this without setting a Photo Library (Add Only) capability with a given reason!
    public static func requestAddOnlyAuthorization() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            return

        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard newStatus == .authorized || newStatus == .limited else {
                throw SaveError.permissionDenied
            }

        case .denied, .restricted:
            throw SaveError.permissionDenied

        @unknown default:
            throw SaveError.unknown
        }
    }

    public enum SaveError: LocalizedError {
        case permissionDenied
        case unknown

        public var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Photo library access was denied. Please enable it in Settings."
            case .unknown:
                return "An unknown error occurred."
            }
        }
    }
}
