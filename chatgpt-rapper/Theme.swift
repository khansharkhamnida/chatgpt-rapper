import UIKit

// Croquette / "cool weird girl" palette: cream, blush pink, cherry, cocoa.
enum Theme {
    static let cream = UIColor(red: 1.00, green: 0.96, blue: 0.93, alpha: 1)
    static let blush = UIColor(red: 0.96, green: 0.65, blue: 0.75, alpha: 1)
    static let softPink = UIColor(red: 1.00, green: 0.88, blue: 0.91, alpha: 1)
    static let cherry = UIColor(red: 0.78, green: 0.16, blue: 0.30, alpha: 1)
    static let cocoa = UIColor(red: 0.33, green: 0.20, blue: 0.20, alpha: 1)

    static func font(_ style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        let descriptor = base.fontDescriptor
            .addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
            .withDesign(.rounded) ?? base.fontDescriptor
        return UIFont(descriptor: descriptor, size: base.pointSize)
    }
}
