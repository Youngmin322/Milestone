//
//  ProjectURLValidator.swift
//  MileStone
//

import Foundation

enum ProjectURLValidator {
    static func validatedURL(from value: String?) -> URL? {
        guard let normalizedValue = normalizedValue(from: value),
              let components = URLComponents(string: normalizedValue),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host,
              !host.isEmpty else {
            return nil
        }

        return components.url
    }

    static func normalizedValue(from value: String?) -> String? {
        guard let value else { return nil }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    static func valueForPersistence(from value: String?) -> String? {
        guard let normalizedValue = normalizedValue(from: value),
              validatedURL(from: normalizedValue) != nil else {
            return nil
        }

        return normalizedValue
    }
}
