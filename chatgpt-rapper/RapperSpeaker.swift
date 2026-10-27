import AVFoundation

// Reads text aloud with Apple's built-in speech (no network or API key needed).
final class RapperSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    // Only utterances of the current reply count, so a cancelled older one can't end the dance early.
    private var pending = Set<ObjectIdentifier>()

    var onStart: (() -> Void)?
    var onFinish: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // Best installed English voice: Premium > Enhanced > default, skipping novelty voices.
    private static let voice: AVSpeechSynthesisVoice? = {
        let preferredNames = ["Ava", "Zoe", "Samantha", "Serena", "Allison", "Susan", "Karen", "Moira", "Tessa"]
        let voices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("en") && !$0.identifier.contains("speech.synthesis.voice")
        }
        func score(_ v: AVSpeechSynthesisVoice) -> Int {
            let quality = v.quality.rawValue * 10
            let name = preferredNames.firstIndex { v.name.contains($0) }.map { preferredNames.count - $0 } ?? 0
            return quality + name
        }
        return voices.max { score($0) < score($1) }
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }()

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)

        // One utterance per bar, with a short beat between lines, so it flows like a verse.
        let lines = Self.removingEmoji(from: text)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !lines.isEmpty else { return onFinish?() ?? () }

        pending.removeAll()
        for line in lines {
            let utterance = AVSpeechUtterance(string: line)
            utterance.voice = Self.voice
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.1
            utterance.pitchMultiplier = 1.1
            utterance.postUtteranceDelay = 0.12
            pending.insert(ObjectIdentifier(utterance))
            synthesizer.speak(utterance)
        }
    }

    // Emoji are shown in the bubble but skipped when speaking.
    private static func removingEmoji(from text: String) -> String {
        let cleaned = String(text.unicodeScalars.filter { scalar in
            let p = scalar.properties
            let isEmoji = p.isEmojiPresentation || (p.isEmoji && scalar.value > 0xFF) // keeps digits and #, *
            return !isEmoji && scalar.value != 0xFE0F && scalar.value != 0x200D
        })
        return cleaned
            .replacingOccurrences(of: " {2,}", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func stop() {
        pending.removeAll()
        synthesizer.stopSpeaking(at: .immediate)
        onFinish?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.onStart?() }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        DispatchQueue.main.async {
            guard self.pending.remove(id) != nil, self.pending.isEmpty else { return }
            self.onFinish?()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        DispatchQueue.main.async {
            guard self.pending.remove(id) != nil, self.pending.isEmpty else { return }
            self.onFinish?()
        }
    }
}
