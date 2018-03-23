//
//  QDBuddhaListViewController.swift
//  QLadder
//
//  Created by qd-hxt on 2018/3/22.
//  Copyright © 2018年 qding. All rights reserved.
//

import UIKit

class QDBuddhaListViewController: QLBaseViewController {

    private var buddhas: [Buddha] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    
    private var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if buddhas.count == 0 {
            refresh()
        }
    }
    
    func initSubviews() {
        navigationItem.title = "Buddha"
        
        let rightSwitch = UISwitch()
        let rightBarButtonItem = UIBarButtonItem(customView: rightSwitch)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        rightSwitch.setOn(true, animated: false)
        rightSwitch.addTarget(self, action: #selector(rightSwitchDidClick(_:)), for: .valueChanged)
        
        tableView.separatorStyle = .none;
        tableView.showsVerticalScrollIndicator = false;
        
        let nib = UINib(nibName: QDBuddhaCell.identifier(), bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: QDBuddhaCell.identifier())
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = QLColor.C1
        tableView.addSubview(refreshControl)
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadData()
    }
    
    private func loadData() {
        currentPage = 0
        QueryManager.shared.fetchBuddhas(0) { (buddhas, errorMessage) in
            if errorMessage != nil {
                self.showEmptyView()
            } else {
                self.buddhas = buddhas
                self.tableView.reloadData()
                self.currentPage += 1
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    private func loadMoreData() {
        QueryManager.shared.fetchBuddhas(currentPage + 1) { (buddhas, errorMessage) in
            if errorMessage != nil {
                
            } else {
                self.buddhas += buddhas
                self.tableView.reloadData()
                self.currentPage += 1
            }
        }
    }
    
    @objc private func rightSwitchDidClick(_ rightSwitch: UISwitch) {
        let covertMode = rightSwitch.isOn
        if covertMode == QueryManager.shared.covertMode {
            return
        }
        QueryManager.shared.covertMode = covertMode
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc override func emptyViewDidClick(_ gestureRecognizer: UITapGestureRecognizer) {
        refresh()
    }
    
    private func refresh() {
        tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        handleRefresh(refreshControl)
        hideEmptyView()
    }
}

extension QDBuddhaListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddhas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: QDBuddhaCell.identifier()) as? QDBuddhaCell {
            let buddha = buddhas[indexPath.row] as Buddha
            cell.buddha = buddha
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QDBuddhaCell.height()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = buddhas.count - 1
        if !refreshControl.isRefreshing && indexPath.row == lastElement {
            //            indicator.startAnimating()
            loadMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let buddha = buddhas[indexPath.row] as Buddha
        let vc = QDBuddhaViewController(buddha)
        navigationController?.pushViewController(vc, animated: true)
    }
}
