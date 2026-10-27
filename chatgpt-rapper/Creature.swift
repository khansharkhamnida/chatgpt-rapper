import UIKit

// What the user says they are ("i'm a mermaid"); changes their avatar, bubble colour and Dahyun's jokes.
struct Creature: Equatable {
    let name: String
    let emoji: String

    // A stable pastel per creature, so a mermaid is always the same colour.
    var tint: UIColor {
        let seed = name.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) % 360 }
        return UIColor(hue: CGFloat(seed) / 360, saturation: 0.32, brightness: 1, alpha: 1)
    }

    private static let key = "userCreature"

    static var current: Creature? = {
        guard let name = UserDefaults.standard.string(forKey: key) else { return nil }
        return catalog[name]
    }() {
        didSet { UserDefaults.standard.set(current?.name, forKey: key) }
    }

    private static let catalog: [String: Creature] = {
        let pairs: [(String, String)] = [
            ("human", "🧑"), ("alien", "👽"), ("mermaid", "🧜‍♀️"), ("merman", "🧜‍♂️"), ("fairy", "🧚"),
            ("vampire", "🧛"), ("ghost", "👻"), ("wizard", "🧙"), ("witch", "🧙‍♀️"), ("elf", "🧝"),
            ("genie", "🧞"), ("zombie", "🧟"), ("robot", "🤖"), ("angel", "😇"), ("demon", "😈"),
            ("ninja", "🥷"), ("pirate", "🏴‍☠️"), ("superhero", "🦸"), ("dragon", "🐉"), ("unicorn", "🦄"),
            ("dinosaur", "🦖"), ("cat", "🐱"), ("dog", "🐶"), ("bunny", "🐰"), ("rabbit", "🐰"),
            ("fox", "🦊"), ("bear", "🐻"), ("panda", "🐼"), ("koala", "🐨"), ("lion", "🦁"),
            ("tiger", "🐯"), ("monkey", "🐵"), ("pig", "🐷"), ("cow", "🐮"), ("frog", "🐸"),
            ("chicken", "🐔"), ("penguin", "🐧"), ("duck", "🦆"), ("owl", "🦉"), ("eagle", "🦅"),
            ("parrot", "🦜"), ("flamingo", "🦩"), ("swan", "🦢"), ("shark", "🦈"), ("dolphin", "🐬"),
            ("whale", "🐳"), ("octopus", "🐙"), ("jellyfish", "🪼"), ("crab", "🦀"), ("turtle", "🐢"),
            ("snake", "🐍"), ("lizard", "🦎"), ("crocodile", "🐊"), ("butterfly", "🦋"), ("bee", "🐝"),
            ("ladybug", "🐞"), ("spider", "🕷️"), ("snail", "🐌"), ("hamster", "🐹"), ("mouse", "🐭"),
            ("sloth", "🦥"), ("otter", "🦦"), ("raccoon", "🦝"), ("hedgehog", "🦔"), ("squirrel", "🐿️"),
            ("bat", "🦇"), ("wolf", "🐺"), ("horse", "🐴"), ("deer", "🦌"), ("giraffe", "🦒"),
            ("elephant", "🐘"), ("zebra", "🦓"), ("cheetah", "🐆"), ("kangaroo", "🦘"), ("camel", "🐫"),
            ("goat", "🐐"), ("sheep", "🐑"), ("peacock", "🦚"),
        ]
        return Dictionary(pairs.map { ($0.0, Creature(name: $0.0, emoji: $0.1)) }, uniquingKeysWith: { first, _ in first })
    }()

    // Finds "i'm a mermaid", "im an alien", "i turned into a cat", "i identify as a dragon", ...
    static func detect(in text: String) -> Creature? {
        let pattern = #"\b(?:i\s*am|i['’]m|im|i\s+turned\s+into|i\s+became|i\s+identify\s+as|call\s+me)\s+(?:actually\s+|really\s+|secretly\s+|just\s+|now\s+)?(?:(?:an|a|the)\s+)?([a-z]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        for match in regex.matches(in: text, range: range) {
            guard let r = Range(match.range(at: 1), in: text) else { continue }
            var word = text[r].lowercased()
            if word.hasSuffix("s"), catalog[String(word.dropLast())] != nil { word = String(word.dropLast()) }
            if let creature = catalog[word] { return creature }
        }
        return nil
    }
}
