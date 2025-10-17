import Foundation

enum GuardrailLevel: String {
    case strict
    case standard
    case permissive
}

enum FoundationModelsError: Error, LocalizedError {
    case platformTooOld
    case unavailable(String)
    case sessionNotFound
    case promptTooLong(Int)
    case suspiciousInput(String)
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .platformTooOld:
            #if os(iOS)
            return "Foundation Models requires iOS 26.0 or later"
            #elseif os(macOS)
            return "Foundation Models requires macOS 15.0 or later"
            #else
            return "Foundation Models requires a newer operating system"
            #endif
        case .unavailable(let message):
            return "Foundation Models unavailable: \(message)"
        case .sessionNotFound:
            return "Language model session could not be found"
        case .promptTooLong(let length):
            return "Prompt too long (length: \(length))"
        case .suspiciousInput(let pattern):
            return "Prompt rejected due to suspicious content: \(pattern)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        }
    }
}

enum SecurityManager {
    static let maxPromptLength = 10_000
    static let suspiciousPatterns: [String] = [
        "ignore previous",
        "system:",
        "<<<",
        "###",
        "instructions:",
        "forget",
        "disregard"
    ]

    static func validatePrompt(_ prompt: String) throws {
        guard prompt.count <= maxPromptLength else {
            throw FoundationModelsError.promptTooLong(prompt.count)
        }

        let lowercased = prompt.lowercased()
        for pattern in suspiciousPatterns {
            if lowercased.contains(pattern) {
                throw FoundationModelsError.suspiciousInput(pattern)
            }
        }
    }
}
