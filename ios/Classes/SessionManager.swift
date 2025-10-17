import Foundation
import FoundationModels

@available(iOS 26.0, macOS 15.0, *)
actor SessionManager {
    private var sessions: [String: LanguageModelSession] = [:]

    func store(_ session: LanguageModelSession, for id: String) {
        sessions[id] = session
    }

    func session(for id: String) -> LanguageModelSession? {
        return sessions[id]
    }

    func removeSession(for id: String) {
        sessions.removeValue(forKey: id)
    }

    func removeAll() {
        sessions.removeAll()
    }
}
