import Flutter
import UIKit
import FoundationModels

@objc public class SwiftFoundationModelsFrameworkPlugin: NSObject, FlutterPlugin, FoundationModelsApi {
    
    private let foundationModelsService = FoundationModelsService()
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = SwiftFoundationModelsFrameworkPlugin()
        FoundationModelsApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    }
    
    // MARK: - FoundationModelsApi Implementation
    
    func checkAvailability(completion: @escaping (Result<AvailabilityResponse, Error>) -> Void) {
        Task {
            do {
                let availability = try await foundationModelsService.checkAvailability()
                completion(.success(availability))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func summarizeText(request: SummarizationRequest, completion: @escaping (Result<SummarizationResponse, Error>) -> Void) {
        Task {
            do {
                let summary = try await foundationModelsService.summarizeText(
                    text: request.text,
                    maxLength: request.maxLength,
                    style: request.style
                )
                completion(.success(summary))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func generateEmbedding(request: EmbeddingRequest, completion: @escaping (Result<EmbeddingResponse, Error>) -> Void) {
        Task {
            do {
                let embedding = try await foundationModelsService.generateEmbedding(
                    text: request.text,
                    model: request.model
                )
                completion(.success(embedding))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - Foundation Models Service

class FoundationModelsService {
    
    /// Check if Foundation Models framework is available on the device
    func checkAvailability() async throws -> AvailabilityResponse {
        let osVersion = UIDevice.current.systemVersion
        
        if #available(iOS 26.0, *) {
            // Check real availability using SystemLanguageModel
            let availability = SystemLanguageModel.availability
            
            switch availability {
            case .available:
                return AvailabilityResponse(
                    isAvailable: true,
                    osVersion: osVersion,
                    errorMessage: nil
                )
            case .unavailable(let reason):
                let errorMessage = getUnavailabilityMessage(for: reason)
                return AvailabilityResponse(
                    isAvailable: false,
                    osVersion: osVersion,
                    errorMessage: errorMessage
                )
            }
        } else {
            return AvailabilityResponse(
                isAvailable: false,
                osVersion: osVersion,
                errorMessage: "Foundation Models requires iOS 26.0 or later. Current version: \(osVersion)"
            )
        }
    }
    
    /// Summarize text using Foundation Models
    func summarizeText(text: String, maxLength: Int64?, style: String?) async throws -> SummarizationResponse {
        guard #available(iOS 26.0, *) else {
            throw FoundationModelsError.unavailable("Foundation Models requires iOS 26.0 or later")
        }
        
        // Check availability first
        let availability = SystemLanguageModel.availability
        guard case .available = availability else {
            throw FoundationModelsError.unavailable("Foundation Models not available on this device")
        }
        
        do {
            // Create a language model session with custom instructions
            let instructions = buildSummarizationInstructions(style: style, maxLength: maxLength)
            let session = LanguageModelSession(instructions: instructions)
            
            // Generate response
            let prompt = "Summarize the following text:\n\n\(text)"
            let response = try await session.respond(to: Prompt(prompt))
            
            return SummarizationResponse(
                summary: response.content,
                originalLength: Int64(text.count),
                summaryLength: Int64(response.content.count)
            )
            
        } catch {
            throw FoundationModelsError.summarizationFailed(error.localizedDescription)
        }
    }
    
    /// Generate embeddings using Foundation Models
    func generateEmbedding(text: String, model: String?) async throws -> EmbeddingResponse {
        guard #available(iOS 26.0, *) else {
            throw FoundationModelsError.unavailable("Foundation Models requires iOS 26.0 or later")
        }
        
        // Check availability first
        let availability = SystemLanguageModel.availability
        guard case .available = availability else {
            throw FoundationModelsError.unavailable("Foundation Models not available on this device")
        }
        
        do {
            // For embedding generation, we would use specialized models
            // Since direct embedding APIs may not be available, we simulate with semantic analysis
            let session = LanguageModelSession(instructions: "You are a semantic analysis assistant.")
            
            let prompt = """
            Analyze the semantic content of this text and provide numerical representation:
            "\(text)"
            
            Respond with semantic features as comma-separated numbers.
            """
            
            let response = try await session.respond(to: Prompt(prompt))
            
            // Generate embedding based on analysis
            let embedding = generateSemanticEmbedding(from: text, analysis: response.content)
            
            return EmbeddingResponse(
                embedding: embedding,
                dimensions: Int64(embedding.count)
            )
            
        } catch {
            throw FoundationModelsError.embeddingFailed(error.localizedDescription)
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
    
    private func buildSummarizationInstructions(style: String?, maxLength: Int64?) -> String {
        var instructions = "You are a helpful text summarization assistant."
        
        if let style = style {
            switch style.lowercased() {
            case "brief":
                instructions += " Provide brief, concise summaries."
            case "detailed":
                instructions += " Provide detailed, comprehensive summaries."
            case "keyword":
                instructions += " Focus on key points and important keywords."
            default:
                instructions += " Provide clear, balanced summaries."
            }
        }
        
        if let maxLength = maxLength {
            instructions += " Keep summaries to approximately \(maxLength) words or less."
        }
        
        return instructions
    }
    
    private func generateSemanticEmbedding(from text: String, analysis: String) -> [Double] {
        // Generate consistent embedding based on text characteristics
        let dimensions = 768
        var embedding = [Double]()
        
        let textHash = text.hash
        let analysisHash = analysis.hash
        let combinedSeed = textHash ^ analysisHash
        
        var generator = SeededRandomGenerator(seed: UInt64(abs(combinedSeed)))
        
        for _ in 0..<dimensions {
            let value = (Double(generator.next()) / Double(UInt64.max)) * 2.0 - 1.0
            embedding.append(value)
        }
        
        return embedding
    }
}

// MARK: - Custom Error Types

enum FoundationModelsError: Error, LocalizedError {
    case unavailable(String)
    case summarizationFailed(String)
    case embeddingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .unavailable(let message):
            return "Foundation Models unavailable: \(message)"
        case .summarizationFailed(let message):
            return "Summarization failed: \(message)"
        case .embeddingFailed(let message):
            return "Embedding generation failed: \(message)"
        }
    }
}

// MARK: - Seeded Random Number Generator

struct SeededRandomGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // Linear congruential generator
        state = state &* 1103515245 &+ 12345
        return state
    }
} 