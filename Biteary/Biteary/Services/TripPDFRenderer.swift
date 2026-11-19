//
//  TripPDFRenderer.swift
//  Biteary
//

import Foundation
import SwiftUI
import UIKit

/// Snapshot of trip-level summary metrics rendered in the PDF header.
struct TripGuideSummary {
    let folderName: String
    let startDate: Date
    let endDate: Date
    let folderColor: Color
    let folderBackColor: Color
    let dishCount: Int
    let averageRating: Double?
    let totalSpend: Double
    let currencyCode: String

    var formattedAverageRating: String {
        guard let averageRating else { return "—" }
        return String(format: "%.1f / 5", averageRating)
    }

    var formattedDateRange: String {
        let start = startDate.formatted(date: .abbreviated, time: .omitted)
        let end = endDate.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)"
    }
}

/// Immutable display model for a dish card inside ``TripGuidePDFView``.
struct TripGuideDishItem: Identifiable {
    let id: UUID
    let dishName: String
    let restaurantName: String
    let city: String
    let price: Double
    let rating: Int
    let date: Date
    let notes: String
    let thumbnail: UIImage?

    var locationLine: String {
        let parts = [restaurantName, city]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? "Location not recorded" : parts.joined(separator: " • ")
    }
}

/// Renders a styled, paginated A4 Culinary Guide PDF for a ``Folder`` using SwiftUI
/// ``ImageRenderer`` and ``UIGraphicsPDFRenderer``.
@MainActor
enum TripPDFRenderer {
    /// Standard A4 page dimensions in PDF points (72 dpi).
    static let pageSize = CGSize(width: 595, height: 842)

    private static let dishesPerPage = 4

    /// Generates an A4 PDF culinary guide for `folder` in `FileManager.default.temporaryDirectory`.
    static func render(folder: Folder) throws -> URL {
        let currencyCode = Locale.current.currency?.identifier ?? "EUR"
        let foods = folder.foods
        let totalSpend = foods.reduce(0.0) { $0 + $1.price }
        let averageRating: Double? = foods.isEmpty
            ? nil
            : Double(foods.reduce(0) { $0 + $1.rating }) / Double(foods.count)

        let summary = TripGuideSummary(
            folderName: folder.name,
            startDate: folder.startDate,
            endDate: folder.endDate,
            folderColor: folder.getFolderColor(),
            folderBackColor: folder.getFolderBackColor(),
            dishCount: foods.count,
            averageRating: averageRating,
            totalSpend: totalSpend,
            currencyCode: currencyCode
        )

        let dishItems: [TripGuideDishItem] = foods.map { food in
            TripGuideDishItem(
                id: food.id,
                dishName: food.dishName,
                restaurantName: food.restaurantName,
                city: food.city,
                price: food.price,
                rating: food.rating,
                date: food.date,
                notes: food.notes,
                thumbnail: food.getThumbnail(maxPixelSize: 600)
            )
        }

        let pages: [[TripGuideDishItem]]
        if dishItems.isEmpty {
            pages = [[]]
        } else {
            pages = stride(from: 0, to: dishItems.count, by: dishesPerPage).map { startIndex in
                let endIndex = min(startIndex + dishesPerPage, dishItems.count)
                return Array(dishItems[startIndex..<endIndex])
            }
        }

        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BitearyGuides", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let fileURL = outputDirectory.appendingPathComponent(sanitizedFilename(for: folder.name))

        let pageRect = CGRect(origin: .zero, size: pageSize)
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextCreator as String: "Biteary",
            kCGPDFContextAuthor as String: "Biteary Travel Food Journal",
            kCGPDFContextTitle as String: "\(folder.name) — Culinary Guide"
        ]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        try pdfRenderer.writePDF(to: fileURL) { pdfContext in
            for (index, pageDishes) in pages.enumerated() {
                pdfContext.beginPage()

                let pageView = TripGuidePDFView(
                    summary: summary,
                    dishes: pageDishes,
                    pageNumber: index + 1,
                    totalPages: pages.count
                )
                .frame(width: pageSize.width, height: pageSize.height)
                .environment(\.colorScheme, .light)

                let imageRenderer = ImageRenderer(content: pageView)
                imageRenderer.proposedSize = ProposedViewSize(pageSize)
                imageRenderer.scale = 2.0

                let cgContext = pdfContext.cgContext
                cgContext.saveGState()
                // UIGraphicsPDFRenderer uses UIKit's flipped top-left coordinate space,
                // while ImageRenderer draws in Core Graphics bottom-left coordinates.
                cgContext.translateBy(x: 0, y: pageRect.height)
                cgContext.scaleBy(x: 1, y: -1)

                imageRenderer.render { _, renderInContext in
                    renderInContext(cgContext)
                }

                cgContext.restoreGState()
            }
        }

        return fileURL
    }

    /// Produces a filesystem-safe `.pdf` filename from a folder's display name.
    static func sanitizedFilename(for folderName: String) -> String {
        let trimmed = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " -_"))
        let cleanedScalars = trimmed.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let collapsed = String(cleanedScalars)
            .replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)
            .replacingOccurrences(of: #"-+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-_. "))

        let base = collapsed.isEmpty ? "Trip-Guide" : String(collapsed.prefix(60))
        return "\(base)-Culinary-Guide.pdf"
    }
}

/// SwiftUI print layout representing a single A4 page of a Biteary Trip Culinary Guide.
struct TripGuidePDFView: View {
    let summary: TripGuideSummary
    let dishes: [TripGuideDishItem]
    let pageNumber: Int
    let totalPages: Int

    private let horizontalPadding: CGFloat = 36
    private let verticalPadding: CGFloat = 32
    private let gridSpacing: CGFloat = 16
    private let cardWidth: CGFloat = 253.5
    private let cardHeight: CGFloat = 264

    private var dishRows: [[TripGuideDishItem]] {
        stride(from: 0, to: dishes.count, by: 2).map { index in
            Array(dishes[index..<min(index + 2, dishes.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if pageNumber == 1 {
                heroHeader
            } else {
                continuationHeader
            }

            if dishes.isEmpty {
                emptyStateCard
            } else {
                VStack(alignment: .leading, spacing: gridSpacing) {
                    ForEach(Array(dishRows.enumerated()), id: \.offset) { _, row in
                        HStack(alignment: .top, spacing: gridSpacing) {
                            ForEach(row) { dish in
                                dishCard(dish)
                            }
                            if row.count == 1 {
                                Color.clear
                                    .frame(width: cardWidth, height: cardHeight)
                            }
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            footer
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(width: TripPDFRenderer.pageSize.width, height: TripPDFRenderer.pageSize.height)
        .background(Color.white)
    }

    private var heroHeader: some View {
        ZStack(alignment: .topLeading) {
            // Subtle layered folder tab inspired by FolderButton
            RoundedRectangle(cornerRadius: 15)
                .fill(summary.folderBackColor.gradient)
                .frame(width: 190, height: 34)
                .offset(y: -10)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BITEARY CULINARY GUIDE")
                            .font(.system(size: 9.5, weight: .bold))
                            .tracking(1.3)
                            .foregroundStyle(.white.opacity(0.88))

                        Text(summary.folderName.isEmpty ? "Untitled Trip" : summary.folderName)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        HStack(spacing: 5) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11, weight: .semibold))
                            Text(summary.formattedDateRange)
                                .font(.system(size: 11.5, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.92))
                    }

                    Spacer()

                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.9))
                }

                HStack(spacing: 10) {
                    statPill(
                        icon: "fork.knife",
                        title: summary.dishCount == 1 ? "Dish" : "Dishes",
                        value: "\(summary.dishCount)"
                    )
                    statPill(
                        icon: "star.fill",
                        title: "Avg Rating",
                        value: summary.formattedAverageRating
                    )
                    statPill(
                        icon: "banknote",
                        title: "Total Spend",
                        value: summary.totalSpend.formatted(.currency(code: summary.currencyCode))
                    )
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(summary.folderColor.gradient)
            )
        }
        .padding(.top, 10)
    }

    private var continuationHeader: some View {
        HStack {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(summary.folderColor.gradient)
                    .frame(width: 6, height: 22)

                Text(summary.folderName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(white: 0.14))
                    .lineLimit(1)
            }

            Spacer()

            Text("CULINARY GUIDE")
                .font(.system(size: 9.5, weight: .semibold))
                .tracking(1.1)
                .foregroundStyle(summary.folderColor)
        }
        .padding(.bottom, 4)
    }

    private func statPill(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.white.opacity(0.22), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 10))
    }

    private func dishCard(_ dish: TripGuideDishItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let thumbnail = dish.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth - 16, height: 112)
                        .clipped()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(summary.folderColor.opacity(0.14).gradient)
                        VStack(spacing: 4) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(summary.folderColor.opacity(0.75))
                            Text("No Photo")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundStyle(summary.folderColor.opacity(0.75))
                        }
                    }
                    .frame(width: cardWidth - 16, height: 112)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 11))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(dish.dishName.isEmpty ? "Untitled Dish" : dish.dishName)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(Color(white: 0.12))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text(dish.price, format: .currency(code: summary.currencyCode))
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(summary.folderColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(summary.folderColor.opacity(0.12), in: Capsule())
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 9.5))
                    .foregroundStyle(summary.folderColor)
                Text(dish.locationLine)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(Color(white: 0.35))
                    .lineLimit(1)
            }

            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= dish.rating ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundStyle(star <= dish.rating ? Color.orange : Color(white: 0.78))
                }

                Spacer()

                Text(dish.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Color(white: 0.48))
            }

            let trimmedNotes = dish.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedNotes.isEmpty {
                Text(trimmedNotes)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(white: 0.32))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.grayForm.opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(summary.folderColor.opacity(0.22), lineWidth: 1)
        )
    }

    private var emptyStateCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(summary.folderColor)
            Text("No dishes recorded yet for this trip.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(white: 0.38))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.grayForm.opacity(0.65))
        )
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 0.75)

            HStack {
                Text("Biteary • \(summary.folderName)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color(white: 0.48))
                    .lineLimit(1)

                Spacer()

                Text("Page \(pageNumber) of \(totalPages)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(white: 0.42))
            }
        }
    }
}

#Preview {
    TripGuidePDFView(
        summary: TripGuideSummary(
            folderName: "Napoli",
            startDate: .now,
            endDate: .now,
            folderColor: .orangeFolder,
            folderBackColor: .orangeFolderBack,
            dishCount: 2,
            averageRating: 4.5,
            totalSpend: 19.5,
            currencyCode: Locale.current.currency?.identifier ?? "EUR"
        ),
        dishes: [
            TripGuideDishItem(
                id: UUID(),
                dishName: "Pizza Margherita",
                restaurantName: "Da Michele",
                city: "Napoli",
                price: 7.5,
                rating: 5,
                date: .now,
                notes: "Wood-fired crust with San Marzano tomatoes and fior di latte.",
                thumbnail: nil
            ),
            TripGuideDishItem(
                id: UUID(),
                dishName: "Sfogliatella",
                restaurantName: "Attanasio",
                city: "Napoli",
                price: 3.0,
                rating: 4,
                date: .now,
                notes: "Warm, flaky ricotta pastry straight out of the oven.",
                thumbnail: nil
            )
        ],
        pageNumber: 1,
        totalPages: 1
    )
}
