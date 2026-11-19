//
//  TripPDFAndThumbnailTests.swift
//  BitearyTests
//

import Foundation
import PDFKit
import SwiftData
import Testing
import UIKit
@testable import Biteary

struct TripPDFAndThumbnailTests {

    @Test("PDF generation produces a valid, non-empty A4 PDF document from SwiftData records")
    @MainActor
    func pdfGenerationProducesValidDocument() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Folder.self, Food.self, configurations: configuration)
        let context = container.mainContext

        // Generate a synthetic dish photo to exercise image embedding alongside placeholder cards.
        let syntheticPhotoData = try makeSyntheticJPEGData(width: 600, height: 400, color: .systemRed)

        let pizza = Food(
            dishName: "Pizza Margherita",
            restaurantName: "L'Antica Pizzeria da Michele",
            city: "Napoli",
            price: 7.50,
            rating: 5,
            notes: "Pillowy wood-fired crust with San Marzano tomatoes and fior di latte.",
            date: Date(timeIntervalSince1970: 1_728_518_400),
            imageData: [syntheticPhotoData]
        )

        let sfogliatella = Food(
            dishName: "Sfogliatella Riccia",
            restaurantName: "Antico Forno Fratelli Attanasio",
            city: "Napoli",
            price: 3.00,
            rating: 4,
            notes: "Crisp layered pastry filled with warm sweet ricotta.",
            date: Date(timeIntervalSince1970: 1_728_604_800),
            imageData: nil
        )

        let folder = Folder(
            id: UUID(),
            name: "Napoli / Amalfi 2025",
            startDate: Date(timeIntervalSince1970: 1_728_518_400),
            endDate: Date(timeIntervalSince1970: 1_728_777_600),
            color: "orange",
            foods: [pizza, sfogliatella],
            dateCreated: Date(timeIntervalSince1970: 1_728_518_400)
        )

        context.insert(folder)
        try context.save()

        let pdfURL = try TripPDFRenderer.render(folder: folder)
        defer { try? FileManager.default.removeItem(at: pdfURL.deletingLastPathComponent()) }

        #expect(FileManager.default.fileExists(atPath: pdfURL.path))
        #expect(pdfURL.pathExtension.lowercased() == "pdf")
        #expect(!pdfURL.lastPathComponent.contains("/"))

        let pdfData = try Data(contentsOf: pdfURL)
        #expect(!pdfData.isEmpty)

        let document = try #require(PDFDocument(url: pdfURL))
        #expect(document.pageCount >= 1)

        let firstPage = try #require(document.page(at: 0))
        let mediaBox = firstPage.bounds(for: .mediaBox)
        #expect(abs(mediaBox.width - 595) < 1)
        #expect(abs(mediaBox.height - 842) < 1)

        // Verify searchable vector text rendered right-side-up in PDF coordinates
        // (PDF origin is bottom-left: y in 600...842 is the top hero banner; y in 0...100 is the footer).
        let pageText = firstPage.string ?? ""
        #expect(pageText.contains("Napoli / Amalfi 2025"))
        #expect(pageText.contains("Pizza Margherita"))
        #expect(pageText.contains("Sfogliatella Riccia"))

        let topBandText = firstPage.selection(for: CGRect(x: 0, y: 600, width: 595, height: 242))?.string ?? ""
        let bottomBandText = firstPage.selection(for: CGRect(x: 0, y: 0, width: 595, height: 100))?.string ?? ""
        #expect(topBandText.contains("BITEARY CULINARY GUIDE"))
        #expect(bottomBandText.contains("Page 1 of 1"))
    }

    @Test("PDF generation paginates folders with more than 4 dishes across multiple A4 pages")
    @MainActor
    func pdfGenerationPaginatesLargeFolders() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Folder.self, Food.self, configurations: configuration)
        let context = container.mainContext

        let dishes = (1...6).map { index in
            Food(
                dishName: "Dish #\(index)",
                restaurantName: "Trattoria \(index)",
                city: "Roma",
                price: Double(index) * 5.0,
                rating: min(5, index),
                notes: "Tasting note for dish #\(index).",
                date: .now
            )
        }

        let folder = Folder(
            id: UUID(),
            name: "Roma Food Tour",
            startDate: .now,
            endDate: .now,
            color: "blue",
            foods: dishes,
            dateCreated: .now
        )

        context.insert(folder)
        try context.save()

        let pdfURL = try TripPDFRenderer.render(folder: folder)
        defer { try? FileManager.default.removeItem(at: pdfURL.deletingLastPathComponent()) }

        let document = try #require(PDFDocument(url: pdfURL))
        #expect(document.pageCount == 2)
    }

    @Test("Thumbnail downsampling caps a 2000x2000 JPEG at maxPixelSize 300")
    func thumbnailDownsamplingCapsDimensions() throws {
        let downsampler = ThumbnailDownsampler()
        let jpegData = try makeSyntheticJPEGData(width: 2000, height: 2000, color: .systemOrange)

        let thumbnail = try #require(
            downsampler.downsample(data: jpegData, maxPixelSize: 300)
        )
        let cgImage = try #require(thumbnail.cgImage)

        #expect(cgImage.width > 0)
        #expect(cgImage.height > 0)
        #expect(cgImage.width <= 300)
        #expect(cgImage.height <= 300)
        #expect(thumbnail.size.width <= 300)
        #expect(thumbnail.size.height <= 300)

        // Verify subsequent lookup hits the in-memory cache and returns an identical instance.
        let cachedThumbnail = try #require(
            downsampler.downsample(data: jpegData, maxPixelSize: 300)
        )
        #expect(cachedThumbnail === thumbnail)
    }

    @Test("Food.getThumbnail(maxPixelSize:) downsamples stored dish JPEG data")
    @MainActor
    func foodModelThumbnailHelperDownsamplesStoredImage() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Folder.self, Food.self, configurations: configuration)
        let context = container.mainContext

        let jpegData = try makeSyntheticJPEGData(width: 2000, height: 1500, color: .systemGreen)
        let food = Food(dishName: "Ramen", imageData: [jpegData])
        context.insert(food)
        try context.save()

        let thumbnail = try #require(food.getThumbnail(maxPixelSize: 300))
        let cgImage = try #require(thumbnail.cgImage)

        #expect(cgImage.width <= 300)
        #expect(cgImage.height <= 300)
        #expect(cgImage.width > cgImage.height) // Aspect ratio preserved
    }

    // MARK: - Helpers

    private func makeSyntheticJPEGData(width: Int, height: Int, color: UIColor) throws -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true

        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor.white.setFill()
            let insetRect = CGRect(
                x: size.width * 0.2,
                y: size.height * 0.2,
                width: size.width * 0.6,
                height: size.height * 0.6
            )
            context.fill(insetRect)
        }

        return try #require(image.jpegData(compressionQuality: 0.9))
    }
}
