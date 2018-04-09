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
import TinyConstraints

final class UserBotsGroupsViewController: UIViewController {

    private let dataSource = UsersBotsGroupsDataSource()

    private lazy var toolbar: PushedSearchHeaderView = {
        let view = PushedSearchHeaderView()
        view.delegate = self

        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = Theme.viewBackgroundColor
        BasicTableViewCell.register(in: view)
        //view.delegate = self
        //view.dataSource = self
        view.sectionFooterHeight = 0.0
        view.contentInset.bottom = -21
        view.scrollIndicatorInsets.bottom = -21
        view.estimatedRowHeight = 98
        view.alwaysBounceVertical = true
        view.register(RectImageTitleSubtitleTableViewCell.self)
        view.separatorStyle = .none

        return view
    }()



    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.addSubview(toolbar)

        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true

        toolbar.top(to: layoutGuide())
        toolbar.left(to: view)
        toolbar.right(to: view)
        toolbar.height(56)

        tableView.topToBottom(of: toolbar)
        tableView.left(to: view)
        tableView.right(to: view)
        tableView.bottom(to: layoutGuide())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension UserBotsGroupsViewController: PushedSearchHeadrDelegate {
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
