import Foundation
import UIKit

// MARK: - Models

struct LicenseResponse: Codable {
    let valid: Bool
    let status: String?
    let expiresAt: String?
    let hwid: String?

    enum CodingKeys: String, CodingKey {
        case valid
        case status
        case expiresAt = "expires_at"
        case hwid
    }
}

struct LicenseInfo {
    let key: String
    let expiresAt: String
    let deviceName: String
    let hwid: String
}

// MARK: - HWID

enum DeviceID {
    static var hwid: String {
        if let stored = UserDefaults.standard.string(forKey: "ffext_hwid") {
            return stored
        }
        // Generate a stable device ID from identifierForVendor
        let raw = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let hwid = "ios-\(raw.prefix(16).lowercased())"
        UserDefaults.standard.set(hwid, forKey: "ffext_hwid")
        return hwid
    }

    static var deviceName: String {
        UIDevice.current.name
    }
}

// MARK: - Service

enum LicenseService {
    static let apiURL = URL(string: "https://ffexxxx.vercel.app/api/licenses/validate")!
    static let storageKey = "ffext_license_key"
    static let infoKey    = "ffext_license_info"

    // MARK: - Validate

    static func validate(key: String) async throws -> LicenseInfo {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let body: [String: Any] = [
            "key":  key,
            "hwid": DeviceID.hwid
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw LicenseError.networkError
        }
        guard (200..<300).contains(http.statusCode) else {
            throw LicenseError.serverError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(LicenseResponse.self, from: data)
        guard decoded.valid else {
            throw LicenseError.invalidKey
        }

        let expiresAt = decoded.expiresAt ?? "Unknown"
        // Format date if possible
        let formattedExpiry = formatExpiry(expiresAt)

        let info = LicenseInfo(
            key: key,
            expiresAt: formattedExpiry,
            deviceName: DeviceID.deviceName,
            hwid: DeviceID.hwid
        )
        store(key: key)
        return info
    }

    // MARK: - Storage

    static func storedKey() -> String? {
        UserDefaults.standard.string(forKey: storageKey)
    }

    private static func store(key: String) {
        UserDefaults.standard.set(key, forKey: storageKey)
    }

    static func logout() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Helpers

    private static func formatExpiry(_ raw: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: raw) {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            return df.string(from: date)
        }
        return raw
    }

    /// Masks all but the last 4 chars: FFEX-XXXX-XXXX-1234 -> FFEX-••••-••••-1234
    static func maskedKey(_ key: String) -> String {
        let parts = key.components(separatedBy: "-")
        guard parts.count >= 2 else {
            let visible = String(key.suffix(4))
            let hidden  = String(repeating: "•", count: max(0, key.count - 4))
            return hidden + visible
        }
        let last    = parts.last ?? ""
        let prefix  = parts.first ?? ""
        let midMask = Array(repeating: "••••", count: max(0, parts.count - 2))
        return ([prefix] + midMask + [last]).joined(separator: "-")
    }
}

enum LicenseError: LocalizedError {
    case invalidKey
    case networkError
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidKey:         return "Invalid or expired key"
        case .networkError:       return "Network error — check your connection"
        case .serverError(let c): return "Server error (\(c))"
        }
    }
}
