//
//  SecondViewController.swift
//  CustomTabBar
//
//  Created by Zhi Zhou on 2020/7/14.
//  Copyright © 2020 Zhi Zhou. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    private let tableView = UITableView()


    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension SecondViewController {
    
    private func setupInterface() {
        
        title = "Second"
        
        setupTableView()
    }
    
    private func setupTableView() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .cyan
        tableView.contentInset.bottom = (tabBarController as? CurvedTabBarController)?.bottomOffset ?? 0
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        
        cell.textLabel?.text = "Second View Controller - \(indexPath.row)"
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

































