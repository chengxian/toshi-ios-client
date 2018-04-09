// Copyright (c) 2018 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit

protocol PushedSearchHeadrDelegate: class {
    func searchHeaderWillBeginEditing(_ headerView: PushedSearchHeaderView)
    func searchHeaderWillEndEditing(_ headerView: PushedSearchHeaderView)

    func searchHeaderDidReceiveCancelEvent(_ headerView: PushedSearchHeaderView)
    func searchHeaderViewDidReceiveBackEvent(_ headerView: PushedSearchHeaderView)
}

final class PushedSearchHeaderView: UIView {

    weak var delegate: PushedSearchHeadrDelegate?

    var searchPlaceholder: String? {
        didSet {
            searchTextField.placeholder = searchPlaceholder
        }
    }

    private lazy var backButton: UIButton = {
        let view = UIButton()
        view.setTitleColor(Theme.tintColor, for: .normal)
        view.size(CGSize(width: .defaultButtonHeight, height: .defaultButtonHeight))
        view.setImage(ImageAsset.web_back.withRenderingMode(.alwaysTemplate), for: .normal)
        view.tintColor = Theme.tintColor
        view.addTarget(self, action: #selector(self.didTapBackButton), for: .touchUpInside)
        view.contentHorizontalAlignment = .left

        return view
    }()

    private(set) lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.delegate = self
        textField.layer.cornerRadius = 5
        textField.tintColor = Theme.tintColor
        textField.returnKeyType = .go

        return textField
    }()

    private lazy var searchTextFieldBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = Theme.searchBarColor
        backgroundView.layer.cornerRadius = 5
        backgroundView.height(36)

        backgroundView.addSubview(searchTextField)
        searchTextField.leftToSuperview(offset: .mediumInterItemSpacing)
        searchTextField.topToSuperview()
        searchTextField.bottomToSuperview()
        searchTextField.right(to: backgroundView, offset: -.smallInterItemSpacing)

        return backgroundView
    }()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle(Localized.cancel_action_title, for: .normal)
        cancelButton.setTitleColor(Theme.tintColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)

        return cancelButton
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally

        return stackView
    }()

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(stackView)
        stackView.edgesToSuperview()
        stackView.alignment = .center
        stackView.addBackground(with: Theme.viewBackgroundColor)

        stackView.addSpacerView(with: .defaultMargin)
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(searchTextFieldBackgroundView)
        stackView.addSpacing(.smallInterItemSpacing, after: searchTextFieldBackgroundView)

        stackView.addArrangedSubview(cancelButton)
        stackView.addSpacerView(with: .defaultMargin)

        let separator = BorderView()
        addSubview(separator)
        separator.leftToSuperview()
        separator.rightToSuperview()
        separator.bottomToSuperview()
        separator.addHeightConstraint()

        cancelButton.isHidden = true
    }

    private func adjustToSearching(isSearching: Bool) {
        layoutIfNeeded()
        cancelButton.isHidden = !isSearching
        backButton.isHidden = isSearching

        UIView.animate(withDuration: 0.3) {
            self.backButton.alpha = isSearching ? 0 : 1
            self.layoutIfNeeded()
        }
    }

    @objc private func didTapCancelButton() {
        searchTextField.resignFirstResponder()
        delegate?.searchHeaderDidReceiveCancelEvent(self)
    }

    @objc private func didTapBackButton() {
        delegate?.searchHeaderViewDidReceiveBackEvent(self)
    }
}

extension PushedSearchHeaderView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        adjustToSearching(isSearching: true)
        delegate?.searchHeaderWillBeginEditing(self)

        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        adjustToSearching(isSearching: false)
        delegate?.searchHeaderWillEndEditing(self)

        return true
    }
}
