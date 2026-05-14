//
//  FontsDesignViewController.swift
//  Semantic Colors
//
//  Created by Aswani G on 3/18/24.
//  Copyright © 2024 Cocoa Controls. All rights reserved.
//

import UIKit

final class FontsDesignViewController: UITableViewController {

    private let cellIdentifier = "FontDesignCell"
    private let rows: [(name: String, design: UIFontDescriptor.SystemDesign)] = [
        (".default", .default),
        (".rounded", .rounded),
        (".serif", .serif),
        (".monospaced", .monospaced)
    ]

    private var fontSize: CGFloat = 17

    init() {
        super.init(style: .plain)

        title = "Fonts Design"
        tabBarItem.image = UIImage(systemName: "textformat.abc")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = 52
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(FontSizeHeaderView.self, forHeaderFooterViewReuseIdentifier: FontSizeHeaderView.reuseIdentifier)

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let row = rows[indexPath.row]
        let font = font(for: row.design)

        var content = UIListContentConfiguration.subtitleCell()
        content.text = row.name
        content.textProperties.font = font
        content.secondaryText = String(format: "Point Size: %.0f", font.pointSize)
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FontSizeHeaderView.reuseIdentifier) as? FontSizeHeaderView else {
            return nil
        }

        headerView.configure(fontSize: fontSize) { [weak self] fontSize in
            self?.fontSize = fontSize
            self?.tableView.reloadData()
        }
        return headerView
    }

    private func font(for design: UIFontDescriptor.SystemDesign) -> UIFont {
        let bodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let descriptor = bodyDescriptor.withDesign(design) ?? bodyDescriptor
        return UIFont(descriptor: descriptor, size: fontSize)
    }
}

private final class FontSizeHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "FontSizeHeader"

    private let valueField = UITextField()
    private let stepper = UIStepper()
    private var fontSizeDidChange: ((CGFloat) -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        backgroundConfiguration = .listPlainHeaderFooter()
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let titleLabel = UILabel()
        titleLabel.text = "Font Size"
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        valueField.borderStyle = .roundedRect
        valueField.font = .preferredFont(forTextStyle: .subheadline)
        valueField.keyboardType = .numberPad
        valueField.textAlignment = .right
        valueField.delegate = self
        valueField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        valueField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)

        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.addTarget(self, action: #selector(stepperDidChange), for: .valueChanged)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueField, stepper])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 12

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueField.widthAnchor.constraint(equalToConstant: 70).isActive = true
        valueField.setContentHuggingPriority(.required, for: .horizontal)
        stepper.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(fontSize: CGFloat, onChange: @escaping (CGFloat) -> Void) {
        stepper.value = fontSize
        valueField.text = String(format: "%.0f", fontSize)
        fontSizeDidChange = onChange
    }

    @objc private func stepperDidChange() {
        valueField.text = String(format: "%.0f", stepper.value)
        fontSizeDidChange?(stepper.value)
    }

    @objc private func textFieldDidChange() {
        guard let value = Double(valueField.text ?? "") else {
            return
        }

        stepper.value = value
        fontSizeDidChange?(value)
    }

    @objc private func textFieldDidEndEditing() {
        valueField.text = String(format: "%.0f", stepper.value)
    }
}

extension FontSizeHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.allSatisfy(\.isNumber),
              let text = textField.text,
              let textRange = Range(range, in: text)
        else {
            return false
        }

        let updatedText = text.replacingCharacters(in: textRange, with: string)
        guard let value = Int(updatedText) else {
            return updatedText.isEmpty
        }

        return (1...100).contains(value)
    }
}
