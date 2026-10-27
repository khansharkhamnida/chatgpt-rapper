import UIKit

// Lists everything Dahyun remembers; swipe a fact to delete it, or forget it all.
final class MemoryViewController: UITableViewController {
    private let service: RapperChatService
    private let onChange: () -> Void
    var onForgetAll: (() -> Void)?
    var onRemoveOne: (() -> Void)?

    init(service: RapperChatService, onChange: @escaping () -> Void) {
        self.service = service
        self.onChange = onChange
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🧠 what i remember"
        view.backgroundColor = Theme.cream
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "forget all", style: .plain, target: self, action: #selector(forgetAll)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "done", style: .done, target: self, action: #selector(close)
        )
        navigationItem.rightBarButtonItem?.tintColor = Theme.cherry
        updateEmptyState()
    }

    private func updateEmptyState() {
        navigationItem.leftBarButtonItem?.isEnabled = !service.allMemories.isEmpty
        guard service.allMemories.isEmpty else { tableView.backgroundView = nil; return }
        let label = UILabel()
        label.text = "nothing yet~ tell me your name or what you love 🎀"
        label.font = Theme.font(.body)
        label.textColor = Theme.cocoa
        label.textAlignment = .center
        label.numberOfLines = 0
        tableView.backgroundView = label
    }

    @objc private func close() { dismiss(animated: true) }

    @objc private func forgetAll() {
        let alert = UIAlertController(
            title: "forget everything? 🥺",
            message: "Dahyun will forget your name and everything else she remembers about you.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "forget", style: .destructive) { [weak self] _ in
            guard let self else { return }
            service.forgetEverything()
            tableView.reloadData()
            updateEmptyState()
            onChange()
            onForgetAll?()
        })
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        service.allMemories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "🎀 " + service.allMemories[indexPath.row]
        cell.textLabel?.font = Theme.font(.body)
        cell.textLabel?.textColor = Theme.cocoa
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        service.removeMemory(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateEmptyState()
        onChange()
        onRemoveOne?()
    }
}
