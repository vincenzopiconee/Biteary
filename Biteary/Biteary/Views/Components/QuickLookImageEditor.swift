//
//  QuickLookImageEditor.swift
//  Biteary
//

import QuickLook
import SwiftUI
import UIKit

/// SwiftUI bridge around `QLPreviewController` that enables native iOS **Markup** editing
/// directly on a dish's JPEG photo via `.updateContents` editing mode.
struct QuickLookImageEditor: UIViewControllerRepresentable {
    let imageData: Data
    let title: String
    let onSave: (Data) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(
            imageData: imageData,
            title: title,
            onSave: onSave,
            onDismiss: { dismiss() }
        )
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        context.coordinator.prepareTemporaryFile()

        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        previewController.delegate = context.coordinator
        previewController.currentPreviewItemIndex = 0
        previewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak coordinator = context.coordinator] _ in
                coordinator?.finishAndDismiss()
            }
        )

        let navigationController = UINavigationController(rootViewController: previewController)
        navigationController.navigationBar.prefersLargeTitles = false
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Keep the active Quick Look editing session uninterrupted while presented.
    }

    static func dismantleUIViewController(_ uiViewController: UINavigationController, coordinator: Coordinator) {
        coordinator.syncAndCleanup()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        private let title: String
        private let onSave: (Data) -> Void
        private let onDismiss: () -> Void

        private var lastPersistedData: Data
        private var tempDirectoryURL: URL?
        private var tempFileURL: URL?
        private var previewItem: EditablePreviewItem?

        init(
            imageData: Data,
            title: String,
            onSave: @escaping (Data) -> Void,
            onDismiss: @escaping () -> Void
        ) {
            self.lastPersistedData = imageData
            self.title = title
            self.onSave = onSave
            self.onDismiss = onDismiss
            super.init()
        }

        func prepareTemporaryFile() {
            guard tempFileURL == nil else { return }

            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("BitearyMarkup", isDirectory: true)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)

            let fileName = sanitizedPhotoFilename(for: title)
            let fileURL = directory.appendingPathComponent(fileName)

            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                try lastPersistedData.write(to: fileURL, options: .atomic)
                self.tempDirectoryURL = directory
                self.tempFileURL = fileURL
                self.previewItem = EditablePreviewItem(url: fileURL, title: title)
            } catch {
                self.tempDirectoryURL = nil
                self.tempFileURL = nil
                self.previewItem = nil
            }
        }

        func finishAndDismiss() {
            syncFromTemporaryFileIfNeeded()
            onDismiss()
        }

        func syncAndCleanup() {
            syncFromTemporaryFileIfNeeded()
            if let tempDirectoryURL {
                try? FileManager.default.removeItem(at: tempDirectoryURL)
                self.tempDirectoryURL = nil
                self.tempFileURL = nil
                self.previewItem = nil
            }
        }

        // MARK: - QLPreviewControllerDataSource

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            previewItem == nil ? 0 : 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            if let previewItem {
                return previewItem
            }
            let fallbackURL = tempFileURL ?? FileManager.default.temporaryDirectory
            return EditablePreviewItem(url: fallbackURL, title: title)
        }

        // MARK: - QLPreviewControllerDelegate

        func previewController(
            _ controller: QLPreviewController,
            editingModeFor previewItem: any QLPreviewItem
        ) -> QLPreviewItemEditingMode {
            .updateContents
        }

        func previewController(
            _ controller: QLPreviewController,
            didUpdateContentsOf previewItem: any QLPreviewItem
        ) {
            let sourceURL = previewItem.previewItemURL ?? tempFileURL
            persistIfChanged(from: sourceURL)
        }

        func previewController(
            _ controller: QLPreviewController,
            didSaveEditedCopyOf previewItem: any QLPreviewItem,
            at modifiedContentsURL: URL
        ) {
            persistIfChanged(from: modifiedContentsURL)
        }

        func previewControllerWillDismiss(_ controller: QLPreviewController) {
            syncFromTemporaryFileIfNeeded()
        }

        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            syncFromTemporaryFileIfNeeded()
        }

        // MARK: - Persistence Helpers

        private func syncFromTemporaryFileIfNeeded() {
            persistIfChanged(from: tempFileURL)
        }

        private func persistIfChanged(from url: URL?) {
            guard let url,
                  let updatedData = try? Data(contentsOf: url),
                  !updatedData.isEmpty,
                  updatedData != lastPersistedData
            else {
                return
            }

            // Validate that the modified file decodes as an image before persisting into SwiftData.
            guard UIImage(data: updatedData) != nil else {
                return
            }

            lastPersistedData = updatedData

            if Thread.isMainThread {
                onSave(updatedData)
            } else {
                DispatchQueue.main.async { [onSave] in
                    onSave(updatedData)
                }
            }
        }

        private func sanitizedPhotoFilename(for name: String) -> String {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " -_"))
            let cleaned = String(trimmed.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" })
                .replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)
                .replacingOccurrences(of: #"-+"#, with: "-", options: .regularExpression)
                .trimmingCharacters(in: CharacterSet(charactersIn: "-_. "))

            let base = cleaned.isEmpty ? "dish-photo" : String(cleaned.prefix(50))
            return "\(base).jpg"
        }
    }
}

private final class EditablePreviewItem: NSObject, QLPreviewItem {
    let previewItemURL: URL?
    let previewItemTitle: String?

    init(url: URL, title: String) {
        self.previewItemURL = url
        self.previewItemTitle = title
        super.init()
    }
}
