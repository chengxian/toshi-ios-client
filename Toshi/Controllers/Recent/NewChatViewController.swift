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

final class NewChatViewController: UIViewController {

    enum NewChatItem {
        case startGroup
        case inviteFriend

        var title: String {
            switch self {
            case .startGroup:
                return Localized.start_a_new_group
            case .inviteFriend:
                return Localized.recent_invite_a_friend
            }
        }

        var icon: UIImage {
            switch self {
            case .startGroup:
                return ImageAsset.group_icon
            case .inviteFriend:
                return ImageAsset.invite_friend
            }
        }
    }

    private let newChatItems: [NewChatItem] = [.startGroup, .inviteFriend]
    private let dataSource = UsersBotsGroupsDataSource()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = Theme.viewBackgroundColor
        BasicTableViewCell.register(in: view)
        view.delegate = self
        view.dataSource = self
        view.sectionFooterHeight = 0.0
        view.contentInset.bottom = -21
        view.scrollIndicatorInsets.bottom = -21
        view.estimatedRowHeight = 98
        view.alwaysBounceVertical = true
        view.register(RectImageTitleSubtitleTableViewCell.self)
        view.separatorStyle = .none

        BasicTableViewCell.register(in: view)

        return view
    }()

    private lazy var searchHeaderView: PushedSearchHeaderView = {
        let view = PushedSearchHeaderView()
        view.searchPlaceholder = Localized.search_for_name_or_username
        view.delegate = self

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.addSubview(searchHeaderView)

        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true

        searchHeaderView.top(to: layoutGuide())
        searchHeaderView.left(to: view)
        searchHeaderView.right(to: view)
        searchHeaderView.height(56)

        tableView.topToBottom(of: searchHeaderView)
        tableView.left(to: view)
        tableView.right(to: view)
        tableView.bottom(to: layoutGuide())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        preferLargeTitleIfPossible(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension NewChatViewController: PushedSearchHeadrDelegate {
    func searchHeaderWillBeginEditing(_ headerView: PushedSearchHeaderView) {
        dataSource.isSearching = true
    }

    func searchHeaderWillEndEditing(_ headerView: PushedSearchHeaderView) {
        dataSource.isSearching = false
    }

    func searchHeaderDidReceiveCancelEvent(_ headerView: PushedSearchHeaderView) {

    }

    func searchHeaderViewDidReceiveBackEvent(_ headerView: PushedSearchHeaderView) {
        navigationController?.popViewController(animated: true)
    }
}

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newChatItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < newChatItems.count else { return UITableViewCell() }

        let item = newChatItems[indexPath.row]
        let cellData = TableCellData(title: item.title, leftImage: item.icon)

        let configurator = CellConfigurator()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: configurator.cellIdentifier(for: cellData.components), for: indexPath) as? BasicTableViewCell else { return UITableViewCell() }

        configurator.configureCell(cell, with: cellData)
        cell.titleTextField.textColor = Theme.tintColor

        return cell
    }
}

// MARK: - Mix-in extensions

extension NewChatViewController: SystemSharing { /* mix-in */ }

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < newChatItems.count else { return }

        let item = newChatItems[indexPath.row]

        switch item {
        case .inviteFriend:
            shareWithSystemSheet(item: Localized.sharing_action_item)
        case .startGroup:
            let datasource = ProfilesDataSource(type: .newGroupChat)
            let groupChatSelection = ProfilesViewController(datasource: datasource)
            navigationController?.pushViewController(groupChatSelection, animated: true)
        }
    }
}
