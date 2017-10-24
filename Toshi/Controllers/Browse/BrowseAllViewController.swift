// Copyright (c) 2017 Token Browser, Inc
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

import Foundation
import UIKit

class BrowseAllViewController: UITableViewController {

    private var searchResults: [TokenUser] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private let contentSection: BrowseContentSection

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(_ contentSection: BrowseContentSection) {
        self.contentSection = contentSection
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Theme.viewBackgroundColor

        configureTableView()

        fetchData()
    }

    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInset.bottom = 60
        tableView.register(SearchResultCell.self)
        tableView.estimatedRowHeight = 50
    }

    private func showResults(_ apps: [TokenUser]?, _ error: Error? = nil) {
        if let error = error {
            let alertController = UIAlertController.errorAlert(error as NSError)
            Navigator.presentModally(alertController)
        }

        self.searchResults = apps ?? []
    }

    private func fetchData() {
        switch contentSection {
        case .topRatedApps:
            AppsAPIClient.shared.getTopRatedApps(limit: 100, completion: { [weak self] apps, error in
                self?.showResults(apps, error)
            })
        case .featuredApps:
            AppsAPIClient.shared.getFeaturedApps(limit: 100, completion: { [weak self] apps, error in
                self?.showResults(apps, error)
            })
        case .topRatedPublicUsers:
            IDAPIClient.shared.getTopRatedPublicUsers(limit: 100, completion: { [weak self] users, error in
                self?.showResults(users, error)
            })
        case .latestPublicUsers:
            IDAPIClient.shared.getLatestPublicUsers(limit: 100, completion: { [weak self] users, error in
                 self?.showResults(users, error)
            })
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contact = searchResults.element(at: indexPath.row) {
            Navigator.push(ContactController(contact: contact))
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SearchResultCell.self, for: indexPath)

        if let item = searchResults.element(at: indexPath.row) {
            cell.nameLabel.text = item.name
            cell.usernameLabel.text = item.isApp ? item.about : item.username

            AvatarManager.shared.avatar(for: item.avatarPath, completion: { image, path in
                if item.avatarPath == path {
                    cell.avatarImageView.image = image
                }
            })
        }

        return cell
    }
}
