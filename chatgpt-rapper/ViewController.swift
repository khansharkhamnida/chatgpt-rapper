import UIKit

final class ViewController: UIViewController {
    private let chatService = RapperChatService()
    private let speaker = RapperSpeaker()
    private static let welcome = BubbleMessage(
        text: "yo yo~ dahyun rap mentor in the house, ask me anything lah! 🦅🎀", isUser: false
    )
    private static let saveKey = "savedChat"
    private static let contextKey = "contextStart"
    // Messages before this index are shown but no longer sent to the model.
    private var contextStart = 0
    private var messages: [BubbleMessage] = [ViewController.welcome]

    private let newChatButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "sparkles")
        config.baseForegroundColor = Theme.cherry
        return UIButton(configuration: config)
    }()

    private let memoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "brain.head.profile")
        config.baseForegroundColor = Theme.cherry
        return UIButton(configuration: config)
    }()

    private let chipsScroll: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    private let chipsStack = UIStackView()
    private let defaultStarters = ["build a snowman ⛄", "hype me up 🔥", "teach me a rhyme 🎤", "i'm hungry 🍜", "it's raining 🌧️"]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎀 dahyun's rap club 🍒"
        label.font = Theme.font(.title2, weight: .bold)
        label.textColor = Theme.cherry
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "bars, bows & bad decisions"
        label.font = Theme.font(.footnote)
        label.textColor = Theme.cocoa
        label.textAlignment = .center
        return label
    }()

    private let muteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "speaker.wave.2.fill")
        config.baseForegroundColor = Theme.cherry
        return UIButton(configuration: config)
    }()

    private var isMuted = false
    private var animatedRows = Set<Int>()
    private let headerAvatar = AvatarView(emoji: "🦅", size: 56, background: Theme.softPink)

    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.keyboardDismissMode = .interactive
        return table
    }()

    private let promptField: UITextField = {
        let field = UITextField()
        field.placeholder = "spit something here…"
        field.font = Theme.font(.body)
        field.textColor = Theme.cocoa
        field.backgroundColor = .white
        field.borderStyle = .none
        field.layer.cornerRadius = 20
        field.layer.borderWidth = 1.5
        field.layer.borderColor = Theme.blush.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.leftViewMode = .always
        field.returnKeyType = .send
        return field
    }()

    private let sendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.up")
        config.cornerStyle = .capsule
        config.baseBackgroundColor = Theme.cherry
        config.baseForegroundColor = .white
        return UIButton(configuration: config)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.cream
        loadSavedChat()
        addSparkles()
        speaker.onStart = { [weak self] in self?.setDancing(true) }
        speaker.onFinish = { [weak self] in self?.setDancing(false) }
        setupLayout()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        newChatButton.addTarget(self, action: #selector(newChatTapped), for: .touchUpInside)
        memoryButton.addTarget(self, action: #selector(memoryTapped), for: .touchUpInside)
        setupChips()
        promptField.addTarget(self, action: #selector(sendTapped), for: .editingDidEndOnExit)
    }

    // Floating decorations behind the chat.
    private func addSparkles() {
        let decorations: [(String, CGFloat, CGFloat)] = [
            ("✨", 0.2, 0.25), ("🎀", 1.7, 0.4), ("🍒", 0.3, 0.7), ("🌸", 1.6, 0.85),
            ("⭐️", 1.0, 0.55), ("🦋", 0.25, 1.05), ("💿", 1.75, 1.2), ("🧸", 1.0, 1.5),
        ]
        for (index, item) in decorations.enumerated() {
            let label = UILabel()
            label.text = item.0
            label.font = .systemFont(ofSize: 28)
            label.alpha = 0.35
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: item.1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: item.2, constant: 0),
            ])
            UIView.animate(withDuration: 2.5 + Double(index) * 0.3, delay: Double(index) * 0.2,
                           options: [.autoreverse, .repeat, .allowUserInteraction]) {
                label.transform = CGAffineTransform(translationX: 0, y: -12).rotated(by: 0.2)
            }
        }
    }

    private func setupLayout() {
        let inputRow = UIStackView(arrangedSubviews: [promptField, sendButton])
        inputRow.spacing = 8
        inputRow.alignment = .center
        inputRow.translatesAutoresizingMaskIntoConstraints = false

        let inputBar = UIView()
        inputBar.backgroundColor = Theme.softPink
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(inputRow)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        newChatButton.translatesAutoresizingMaskIntoConstraints = false
        memoryButton.translatesAutoresizingMaskIntoConstraints = false
        chipsScroll.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerAvatar.translatesAutoresizingMaskIntoConstraints = false
        headerAvatar.isUserInteractionEnabled = true
        headerAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        view.addSubview(headerAvatar)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(muteButton)
        view.addSubview(newChatButton)
        view.addSubview(memoryButton)
        view.addSubview(chipsScroll)
        view.addSubview(tableView)
        view.addSubview(inputBar)

        NSLayoutConstraint.activate([
            headerAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerAvatar.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: headerAvatar.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            muteButton.centerYAnchor.constraint(equalTo: headerAvatar.centerYAnchor),
            muteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: chipsScroll.topAnchor),

            newChatButton.centerYAnchor.constraint(equalTo: headerAvatar.centerYAnchor),
            newChatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            memoryButton.centerYAnchor.constraint(equalTo: headerAvatar.centerYAnchor),
            memoryButton.leadingAnchor.constraint(equalTo: newChatButton.trailingAnchor),

            chipsScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsScroll.bottomAnchor.constraint(equalTo: inputBar.topAnchor),
            chipsScroll.heightAnchor.constraint(equalToConstant: 44),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            inputRow.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: 8),
            inputRow.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor, constant: -8),
            inputRow.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),
            inputRow.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),

            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            promptField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    // The "Eagle Dance": the avatar flaps and bounces while Dahyun is talking.
    private func setDancing(_ dancing: Bool) {
        headerAvatar.layer.removeAnimation(forKey: "dance")
        guard dancing else { return }

        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wobble.values = [0, -0.35, 0.35, -0.2, 0.2, 0]
        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [0, -12, 0, -8, 0, 0]
        let group = CAAnimationGroup()
        group.animations = [wobble, bounce]
        group.duration = 0.7
        group.repeatCount = .infinity
        headerAvatar.layer.add(group, forKey: "dance")
    }

    // Tap the avatar for an emoji confetti burst.
    @objc
    private func avatarTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let origin = headerAvatar.convert(CGPoint(x: headerAvatar.bounds.midX, y: headerAvatar.bounds.midY), to: view)
        let emojis = ["🦅", "🎀", "✨", "🍒", "💖", "🎤", "🌸", "⭐️"]

        for i in 0..<16 {
            let label = UILabel()
            label.text = emojis[i % emojis.count]
            label.font = .systemFont(ofSize: CGFloat.random(in: 22...34))
            label.sizeToFit()
            label.center = origin
            view.addSubview(label)

            let angle = CGFloat.random(in: 0..<(2 * .pi))
            let distance = CGFloat.random(in: 80...200)
            UIView.animate(withDuration: 1.1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                label.center = CGPoint(x: origin.x + cos(angle) * distance, y: origin.y + sin(angle) * distance + 60)
                label.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -1...1))
            }
            UIView.animate(withDuration: 0.5, delay: 0.7, options: []) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }

    private func setupChips() {
        chipsStack.spacing = 8
        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        chipsScroll.addSubview(chipsStack)

        NSLayoutConstraint.activate([
            chipsStack.leadingAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.leadingAnchor, constant: 12),
            chipsStack.trailingAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.trailingAnchor, constant: -12),
            chipsStack.topAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.topAnchor, constant: 4),
            chipsStack.bottomAnchor.constraint(equalTo: chipsScroll.contentLayoutGuide.bottomAnchor, constant: -4),
            chipsStack.heightAnchor.constraint(equalTo: chipsScroll.frameLayoutGuide.heightAnchor, constant: -8),
        ])

        reloadChips()
        chatService.onSuggestionsChanged = { [weak self] _ in self?.reloadChips() }
    }

    // Personalised ideas first, then a few of the classics.
    private func reloadChips() {
        let personal = chatService.suggestions
        let titles = personal + defaultStarters.prefix(max(2, 5 - personal.count))

        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, title) in titles.enumerated() {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.cornerStyle = .capsule
            let isPersonal = index < personal.count
            config.baseBackgroundColor = isPersonal ? Theme.blush : .white
            config.baseForegroundColor = Theme.cherry
            config.background.strokeColor = isPersonal ? Theme.cherry : Theme.blush
            config.background.strokeWidth = 1.5
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
                var attrs = attrs
                attrs.font = Theme.font(.subheadline, weight: .semibold)
                return attrs
            }
            chipsStack.addArrangedSubview(UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
                self?.promptField.text = title
                self?.sendTapped()
            }))
        }
        chipsScroll.setContentOffset(.zero, animated: false)
    }

    // The chat survives relaunches; the service rebuilds its context from it.
    private func saveChat() {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: Self.saveKey)
    }

    private func loadSavedChat() {
        guard let data = UserDefaults.standard.data(forKey: Self.saveKey),
              let saved = try? JSONDecoder().decode([BubbleMessage].self, from: data),
              !saved.isEmpty else { return }
        messages = saved
        animatedRows = Set(saved.indices) // no pop-in for old messages
        contextStart = UserDefaults.standard.integer(forKey: Self.contextKey)
        chatService.restore(from: Array(saved.dropFirst(max(1, contextStart))))
    }

    // After a single fact is deleted, earlier messages stay on screen but are hidden from the model.
    private func cutContext() {
        contextStart = messages.count + 1
        UserDefaults.standard.set(contextStart, forKey: Self.contextKey)
        addMessage(BubbleMessage(text: "okay~ i forgot that one 🧹✨", isUser: false))
        saveChat()
    }

    @objc
    private func memoryTapped() {
        let controller = MemoryViewController(service: chatService) { [weak self] in self?.reloadChips() }
        // Erasing everything also clears the chat, so the old name can't be read back from it.
        controller.onForgetAll = { [weak self] in self?.newChatTapped() }
        controller.onRemoveOne = { [weak self] in self?.cutContext() }
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.tintColor = Theme.cherry
        nav.navigationBar.titleTextAttributes = [.foregroundColor: Theme.cherry]
        present(nav, animated: true)
    }

    @objc
    private func newChatTapped() {
        speaker.stop()
        chatService.resetConversation()
        UserDefaults.standard.removeObject(forKey: Self.saveKey)
        UserDefaults.standard.removeObject(forKey: Self.contextKey)
        contextStart = 0
        animatedRows.removeAll()
        messages = [Self.welcome]
        tableView.reloadData()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc
    private func muteTapped() {
        isMuted.toggle()
        muteButton.configuration?.image = UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
        if isMuted { speaker.stop() }
    }

    @objc
    private func sendTapped() {
        guard let prompt = promptField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !prompt.isEmpty, sendButton.isEnabled else { return }

        promptField.text = ""
        speaker.stop()
        setDancing(true)
        sendButton.isEnabled = false
        addMessage(BubbleMessage(text: prompt, isUser: true))
        addMessage(BubbleMessage(text: "cooking up some bars… 🍳✨", isUser: false))

        Task { @MainActor in
            defer { sendButton.isEnabled = true }
            let reply: String
            var failed = false
            var speakingStarted = false
            defer { if !speakingStarted { setDancing(false) } }
            do {
                reply = try await chatService.respond(to: prompt)
                if !isMuted { speakingStarted = true; speaker.speak(reply) }
            } catch {
                reply = error.localizedDescription
                failed = true
            }
            messages[messages.count - 1] = BubbleMessage(text: reply, isUser: false, isError: failed)
            saveChat()
            let last = IndexPath(row: messages.count - 1, section: 0)
            tableView.reloadRows(at: [last], with: .none)
            tableView.scrollToRow(at: last, at: .bottom, animated: true)
        }
    }

    private func addMessage(_ message: BubbleMessage) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
    // Bubbles pop in the first time they appear.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard animatedRows.insert(indexPath.row).inserted else { return }
        cell.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            cell.transform = .identity
            cell.alpha = 1
        }
    }

    // Tap a bot bubble to hear it again.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        guard !message.isUser else { return }
        speaker.speak(message.text)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.reuseID, for: indexPath) as! ChatBubbleCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}
