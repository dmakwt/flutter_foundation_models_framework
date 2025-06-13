import Flutter
import UIKit
import FoundationModels

@objc public class SwiftFoundationModelsFrameworkPlugin: NSObject, FlutterPlugin, FoundationModelsApi {
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = SwiftFoundationModelsFrameworkPlugin()
        FoundationModelsApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    }
    
    // MARK: - FoundationModelsApi Implementation
    
    func checkAvailability(completion: @escaping (Result<AvailabilityResponse, Error>) -> Void) {
        let osVersion = UIDevice.current.systemVersion
        
        if #available(iOS 26.0, *) {
            // Use the correct Apple Foundation Models framework API
            let model = SystemLanguageModel.default
            
            switch model.availability {
            case .available:
                completion(.success(AvailabilityResponse(
                    isAvailable: true,
                    osVersion: osVersion,
                    errorMessage: nil
                )))
            case .unavailable(let reason):
                let errorMessage = getUnavailabilityMessage(for: reason)
                completion(.success(AvailabilityResponse(
                    isAvailable: false,
                    osVersion: osVersion,
                    errorMessage: errorMessage
                )))
            }
        } else {
            completion(.success(AvailabilityResponse(
                isAvailable: false,
                osVersion: osVersion,
                errorMessage: "Foundation Models requires iOS 26.0 or later. Current version: \(osVersion)"
            )))
        }
    }
    
    func sendPrompt(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        Task {
            await handleSendPrompt(request: request, completion: completion)
        }
    }
    
    private func handleSendPrompt(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void) async {
        guard #available(iOS 26.0, *) else {
            completion(.success(ChatResponse(
                content: "",
                errorMessage: "Foundation Models requires iOS 26.0 or later"
            )))
            return
        }
        
        // Check availability first using the correct API
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            completion(.success(ChatResponse(
                content: "",
                errorMessage: "Foundation Models not available on this device"
            )))
            return
        }
        
        do {
            // Create a language model session using the correct Apple API
            let session = LanguageModelSession()
            
            // Send prompt using the correct respond method
            let response = try await session.respond(to: request.prompt)
            
            completion(.success(ChatResponse(
                content: response.content,
                errorMessage: nil
            )))
            
        } catch {
            completion(.success(ChatResponse(
                content: "",
                errorMessage: "Error generating response: \(error.localizedDescription)"
            )))
        }
    }
    
    // MARK: - Helper Methods
    
    @available(iOS 26.0, *)
    private func getUnavailabilityMessage(for reason: SystemLanguageModel.UnavailabilityReason) -> String {
        switch reason {
        case .deviceNotSupported:
            return "Device not supported for Foundation Models"
        case .regionNotSupported:
            return "Foundation Models not available in this region"
        case .disabled:
            return "Foundation Models is disabled. Enable Apple Intelligence in Settings."
        @unknown default:
            return "Foundation Models unavailable: \(reason)"
        }
    }
}

// MARK: - Custom Error Types

enum FoundationModelsError: Error, LocalizedError {
    case unavailable(String)
    case requestFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .unavailable(let message):
            return "Foundation Models unavailable: \(message)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        }
    }
}

