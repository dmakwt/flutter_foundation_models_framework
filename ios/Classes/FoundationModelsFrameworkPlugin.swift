import FoundationModels

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

@objc public class SwiftFoundationModelsFrameworkPlugin: NSObject, FlutterPlugin, FoundationModelsApi {

    @available(iOS 26.0, macOS 15.0, *)
    private let sessionManager = SessionManager()

    private var eventSink: FlutterEventSink?
    private var streamTasks: [String: Task<Void, Never>] = [:]
    private var streamChannel: FlutterEventChannel?

    #if os(iOS)
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = SwiftFoundationModelsFrameworkPlugin()
        let messenger = registrar.messenger()
        FoundationModelsApiSetup.setUp(binaryMessenger: messenger, api: plugin)
        plugin.configureStreamChannel(with: messenger)
    }
    #elseif os(macOS)
    public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = SwiftFoundationModelsFrameworkPlugin()
        let messenger = registrar.messenger
        FoundationModelsApiSetup.setUp(binaryMessenger: messenger, api: plugin)
        plugin.configureStreamChannel(with: messenger)
    }
    #endif

    deinit {
        for (_, task) in streamTasks {
            task.cancel()
        }
    }

    // MARK: - FoundationModelsApi Implementation

    func checkAvailability(completion: @escaping (Result<AvailabilityResponse, Error>) -> Void) {
        #if os(iOS)
        let osVersion = UIDevice.current.systemVersion
        guard #available(iOS 26.0, *) else {
            completion(.success(AvailabilityResponse(
                isAvailable: false,
                osVersion: osVersion,
                reasonCode: "platform_too_old",
                errorMessage: "Foundation Models requires iOS 26.0 or later. Current version: \(osVersion)"
            )))
            return
        }
        #elseif os(macOS)
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        guard #available(macOS 15.0, *) else {
            completion(.success(AvailabilityResponse(
                isAvailable: false,
                osVersion: osVersion,
                reasonCode: "platform_too_old",
                errorMessage: "Foundation Models requires macOS 15.0 or later. Current version: \(osVersion)"
            )))
            return
        }
        #endif

        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            completion(.success(AvailabilityResponse(
                isAvailable: true,
                osVersion: osVersion,
                reasonCode: nil,
                errorMessage: nil
            )))
        case .unavailable(let reason):
            let reasonCode = availabilityReasonCode(for: reason)
            let message = getUnavailabilityMessage(for: reason)
            completion(.success(AvailabilityResponse(
                isAvailable: false,
                osVersion: osVersion,
                reasonCode: reasonCode,
                errorMessage: message
            )))
        }
    }

    func createSession(request: SessionRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        #if os(iOS)
        guard #available(iOS 26.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #elseif os(macOS)
        guard #available(macOS 15.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #endif

        Task {
            do {
                let session = try await buildSession(from: request)
                await sessionManager.store(session, for: request.sessionId)
                completion(.success(()))
            } catch {
                completion(.failure(sanitizeGenerationError(error)))
            }
        }
    }

    func prewarmSession(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if os(iOS)
        guard #available(iOS 26.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #elseif os(macOS)
        guard #available(macOS 15.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #endif

        Task {
            do {
                guard let session = await sessionManager.session(for: sessionId) else {
                    throw FoundationModelsError.sessionNotFound
                }
                session.prewarm()
                completion(.success(()))
            } catch {
                completion(.failure(sanitizeGenerationError(error)))
            }
        }
    }

    func sendPromptToSession(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        #if os(iOS)
        guard #available(iOS 26.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #elseif os(macOS)
        guard #available(macOS 15.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #endif

        Task {
            do {
                try SecurityManager.validatePrompt(request.prompt)
                guard let session = await sessionManager.session(for: request.sessionId) else {
                    throw FoundationModelsError.sessionNotFound
                }

                let options = makeGenerationOptions(from: request.options)
                let response = try await session.respond(to: request.prompt, options: options)

                let transcriptEntries = mapTranscriptEntries(response.transcriptEntries)
                let chatResponse = ChatResponse(
                    content: response.content,
                    rawContent: String(describing: response.rawContent),
                    transcriptEntries: transcriptEntries,
                    errorMessage: nil
                )
                completion(.success(chatResponse))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func disposeSession(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        #if os(iOS)
        guard #available(iOS 26.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #elseif os(macOS)
        guard #available(macOS 15.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #endif

        Task {
            await sessionManager.removeSession(for: sessionId)
            completion(.success(()))
        }
    }

    func startStream(request: ChatStreamRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        #if os(iOS)
        guard #available(iOS 26.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #elseif os(macOS)
        guard #available(macOS 15.0, *) else {
            completion(.failure(FoundationModelsError.platformTooOld))
            return
        }
        #endif

        Task { [weak self] in
            guard let self else { return }
            do {
                let streamId = request.streamId

                let existingTask = await MainActor.run { self.streamTasks[streamId] }
                if let existingTask {
                    existingTask.cancel()
                    _ = await existingTask.value
                    await MainActor.run {
                        self.streamTasks.removeValue(forKey: streamId)
                    }
                }

                guard let session = await sessionManager.session(for: request.sessionId) else {
                    throw FoundationModelsError.sessionNotFound
                }

                guard let sink = await MainActor.run(body: { self.eventSink }) else {
                    throw FoundationModelsError.requestFailed("Stream listener not attached")
                }

                let options = makeGenerationOptions(from: request.options)

                let task = Task { [weak self] in
                    await self?.runStream(
                        streamId: streamId,
                        session: session,
                        prompt: request.prompt,
                        options: options,
                        eventSink: sink
                    )
                }

                await MainActor.run {
                    self.streamTasks[streamId] = task
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    func stopStream(streamId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task { [weak self] in
            guard let self else { return }
            let existingTask = await MainActor.run { self.streamTasks[streamId] }
            if let existingTask {
                existingTask.cancel()
                _ = await existingTask.value
                await MainActor.run {
                    self.streamTasks.removeValue(forKey: streamId)
                    completion(.success(()))
                }
            } else {
                await MainActor.run {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Helper Methods

    @available(iOS 26.0, macOS 15.0, *)
    private func buildSession(from request: SessionRequest) async throws -> LanguageModelSession {
        let modelAvailability = SystemLanguageModel.default.availability
        if case .unavailable(let reason) = modelAvailability {
            throw FoundationModelsError.unavailable(getUnavailabilityMessage(for: reason))
        }

        let model = try makeModel(for: request.guardrailLevel)
        return LanguageModelSession(model: model, instructions: request.instructions)
    }
    
    @available(iOS 26.0, macOS 15.0, *)
    private func makeModel(for guardrailLevel: String?) throws -> SystemLanguageModel {
        guard let guardrailLevel, !guardrailLevel.isEmpty else {
            return .default
        }

        guard let level = GuardrailLevel(rawValue: guardrailLevel) else {
            throw FoundationModelsError.requestFailed("Unknown guardrail level: \(guardrailLevel)")
        }

        switch level {
        case .strict:
            return SystemLanguageModel(useCase: .general, guardrails: .default)
        case .standard:
            return .default
        case .permissive:
            return SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
        }
    }
    
    @available(iOS 26.0, macOS 15.0, *)
    private func makeGenerationOptions(from request: GenerationOptionsRequest?) -> GenerationOptions {
        guard let request else { return GenerationOptions() }

        var options = GenerationOptions()
        if let temperature = request.temperature {
            options.temperature = temperature
        }
        if let maximumResponseTokens = request.maximumResponseTokens {
            options.maximumResponseTokens = Int(maximumResponseTokens)
        }

        if let topK = request.samplingTopK {
            options.sampling = .random(top: Int(topK))
        } else if let probabilityThreshold = request.samplingProbabilityThreshold {
            options.sampling = .random(probabilityThreshold: probabilityThreshold)
        } else if let temperature = request.temperature, temperature <= 0 {
            options.sampling = .greedy
        }

        return options
    }
    
    @available(iOS 26.0, macOS 15.0, *)
    private func mapTranscriptEntries(_ entries: ArraySlice<Transcript.Entry>) -> [TranscriptEntry?] {
        return entries.map { entry in
            let role: String
            let content: String
            let segmentsText: [String]

            switch entry {
            case .instructions(let instructions):
                role = "instructions"
                segmentsText = instructions.segments.map(serializeSegment)
                content = segmentsText.joined(separator: "\n")
            case .prompt(let prompt):
                role = "prompt"
                segmentsText = prompt.segments.map(serializeSegment)
                content = segmentsText.joined(separator: "\n")
            case .toolCalls(let toolCalls):
                role = "tool_calls"
                let description = String(describing: toolCalls)
                segmentsText = [description]
                content = description
            case .toolOutput(let output):
                role = "tool_output"
                let description = String(describing: output)
                segmentsText = [description]
                content = description
            case .response(let response):
                role = "response"
                segmentsText = response.segments.map(serializeSegment)
                content = segmentsText.joined(separator: "\n")
            }

            return TranscriptEntry(id: entry.id, role: role, content: content, segments: segmentsText)
        }
    }

    @available(iOS 26.0, macOS 15.0, *)
    private func serializeSegment(_ segment: Transcript.Segment) -> String {
        switch segment {
        case .text(let textSegment):
            return textSegment.content
        case .structure(let structuredSegment):
            return String(describing: structuredSegment.content)
        }
    }
    @available(iOS 26.0, macOS 15.0, *)
    private func availabilityReasonCode(for reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "device_not_eligible"
        case .appleIntelligenceNotEnabled:
            return "apple_intelligence_not_enabled"
        case .modelNotReady:
            return "model_not_ready"
        @unknown default:
            return "unknown"
        }
    }

    @available(iOS 26.0, macOS 15.0, *)
    private func getUnavailabilityMessage(for reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "Device not eligible for Foundation Models"
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled. Update Settings to proceed."
        case .modelNotReady:
            return "Foundation Models is preparing assets. Please try again shortly."
        @unknown default:
            return "Foundation Models unavailable: \(reason)"
        }
    }

    @available(iOS 26.0, macOS 15.0, *)
    private func sanitizeGenerationError(_ error: Error) -> Error {
        if let generationError = error as? LanguageModelSession.GenerationError {
            switch generationError {
            case .assetsUnavailable(_):
                return FoundationModelsError.requestFailed("Assets unavailable")
            case .concurrentRequests(_):
                return FoundationModelsError.requestFailed("Too many simultaneous requests")
            case .decodingFailure(_):
                return FoundationModelsError.requestFailed("Decoding failure")
            case .exceededContextWindowSize(_):
                return FoundationModelsError.requestFailed("Exceeded context window size")
            case .guardrailViolation(_):
                return FoundationModelsError.requestFailed("Guardrail violation")
            case .rateLimited(_):
                return FoundationModelsError.requestFailed("Rate limited")
            case .refusal(_, _):
                return FoundationModelsError.requestFailed("Content policy refusal")
            case .unsupportedGuide(_):
                return FoundationModelsError.requestFailed("Unsupported guide")
            case .unsupportedLanguageOrLocale(_):
                return FoundationModelsError.requestFailed("Unsupported language or locale")
            }
        }

        if let toolError = error as? LanguageModelSession.ToolCallError {
            return FoundationModelsError.requestFailed("Tool call failed: \(toolError.localizedDescription)")
        }

        return error
    }
}

extension SwiftFoundationModelsFrameworkPlugin: FlutterStreamHandler {
    private func configureStreamChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterEventChannel(name: "dev.flutter.pigeon.foundation_models_framework/stream", binaryMessenger: messenger)
        channel.setStreamHandler(self)
        self.streamChannel = channel
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        for (_, task) in streamTasks {
            task.cancel()
        }
        streamTasks.removeAll()
        return nil
    }
}

@available(iOS 26.0, macOS 15.0, *)
extension SwiftFoundationModelsFrameworkPlugin {
    private func runStream(
        streamId: String,
        session: LanguageModelSession,
        prompt: String,
        options: GenerationOptions,
        eventSink: @escaping FlutterEventSink
    ) async {
        var previous = ""
        var lastRaw: String?

        do {
            let responseStream = session.streamResponse(to: prompt, options: options)

            for try await snapshot in responseStream {
                if Task.isCancelled { break }

                let cumulative = snapshot.content as? String ?? String(describing: snapshot.content)
                let delta: String
                if cumulative.hasPrefix(previous) {
                    delta = String(cumulative.dropFirst(previous.count))
                } else {
                    delta = cumulative
                }
                previous = cumulative
                lastRaw = String(describing: snapshot.rawContent)

                sendStreamEvent(
                    streamId: streamId,
                    delta: delta.isEmpty ? nil : delta,
                    cumulative: cumulative,
                    rawContent: lastRaw,
                    isFinal: false,
                    errorCode: nil,
                    errorMessage: nil
                )
            }

            await MainActor.run {
                self.streamTasks.removeValue(forKey: streamId)
            }

            sendStreamEvent(
                streamId: streamId,
                delta: nil,
                cumulative: previous.isEmpty ? nil : previous,
                rawContent: lastRaw,
                isFinal: true,
                errorCode: nil,
                errorMessage: nil
            )
        } catch is CancellationError {
            await MainActor.run {
                self.streamTasks.removeValue(forKey: streamId)
            }
            sendStreamEvent(
                streamId: streamId,
                delta: nil,
                cumulative: previous.isEmpty ? nil : previous,
                rawContent: lastRaw,
                isFinal: true,
                errorCode: "cancelled",
                errorMessage: "cancelled"
            )
        } catch {
            await MainActor.run {
                self.streamTasks.removeValue(forKey: streamId)
            }
            let sanitized = sanitizeGenerationError(error)
            sendStreamEvent(
                streamId: streamId,
                delta: nil,
                cumulative: previous.isEmpty ? nil : previous,
                rawContent: lastRaw,
                isFinal: true,
                errorCode: String(describing: type(of: sanitized)),
                errorMessage: sanitized.localizedDescription
            )
        }
    }

    private func sendStreamEvent(
        streamId: String,
        delta: String?,
        cumulative: String?,
        rawContent: String?,
        isFinal: Bool,
        errorCode: String?,
        errorMessage: String?
    ) {
        let payload: [String: Any?] = [
            "streamId": streamId,
            "delta": delta,
            "cumulative": cumulative,
            "rawContent": rawContent,
            "isFinal": isFinal,
            "errorCode": errorCode,
            "errorMessage": errorMessage,
        ]
        DispatchQueue.main.async { [weak self] in
            guard let sink = self?.eventSink else { return }
            sink(payload)
        }
    }
}
