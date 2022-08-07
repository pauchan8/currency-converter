//
//  HistoryViewController.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 04.08.2022.
//

import UIKit

class HistoryViewController: UIViewController {
    private struct Constants {
        static let reuseIdentifier = "DefaultCell"
    }
    
    @IBOutlet private var tableView: UITableView!
    
    private let presenter = HistoryPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
    }
    
    @IBAction private func clearHistory() {
        presenter.deleteAll()
        tableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier) ?? UITableViewCell()
        var config = cell.defaultContentConfiguration()
        config.text = presenter.entries[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.entries.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}
