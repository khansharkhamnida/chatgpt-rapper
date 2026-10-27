import UIKit

struct BubbleMessage: Codable {
    let text: String
    let isUser: Bool
    var isError = false
}

// Circle avatar with an emoji, used for both the chat bubbles and the header.
final class AvatarView: UIView {
    private let label = UILabel()

    init(emoji: String, size: CGFloat, background: UIColor) {
        super.init(frame: .zero)
        backgroundColor = background
        layer.cornerRadius = size / 2
        layer.borderWidth = 2
        layer.borderColor = Theme.cherry.cgColor
        label.text = emoji
        label.font = .systemFont(ofSize: size * 0.55)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class ChatBubbleCell: UITableViewCell {
    static let reuseID = "ChatBubbleCell"

    private let bubble = UIView()
    private let label = UILabel()
    private let botAvatar = AvatarView(emoji: "🦅", size: 36, background: Theme.softPink)
    private let userAvatar = AvatarView(emoji: "🍒", size: 36, background: Theme.blush)
    private var botConstraints: [NSLayoutConstraint] = []
    private var userConstraints: [NSLayoutConstraint] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        bubble.layer.borderWidth = 1.5
        bubble.layer.cornerRadius = 20
        bubble.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Theme.font(.body)
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(botAvatar)
        contentView.addSubview(userAvatar)
        contentView.addSubview(bubble)
        bubble.addSubview(label)

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.68),
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14),
        ])

        botConstraints = [
            botAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            botAvatar.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
            bubble.leadingAnchor.constraint(equalTo: botAvatar.trailingAnchor, constant: 8),
        ]
        userConstraints = [
            userAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            userAvatar.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
            bubble.trailingAnchor.constraint(equalTo: userAvatar.leadingAnchor, constant: -8),
        ]
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with message: BubbleMessage) {
        label.text = message.text
        NSLayoutConstraint.deactivate(botConstraints + userConstraints)
        botAvatar.isHidden = message.isUser
        userAvatar.isHidden = !message.isUser

        // The corner next to the avatar stays sharp, like a speech tail.
        if message.isUser {
            NSLayoutConstraint.activate(userConstraints)
            bubble.backgroundColor = Theme.blush
            bubble.layer.borderColor = Theme.cherry.cgColor
            bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            NSLayoutConstraint.activate(botConstraints)
            bubble.backgroundColor = .white
            bubble.layer.borderColor = Theme.blush.cgColor
            bubble.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
        label.textColor = Theme.cocoa
    }
}
