//
//  QLDebugViewController.swift
//  QLadder
//
//  Created by qd-hxt on 2017/11/17.
//  Copyright © 2017年 qding. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

class QLDebugViewController: QLBaseViewController {
    
    private var buddhas: [Buddha] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Debug"
        
        let nib = UINib(nibName: QDBuddhaCell.identifier(), bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: QDBuddhaCell.identifier())
        
        QueryManager.shared.fetchBuddhas(1) { (buddhas, errorMessage) in
            self.buddhas += buddhas
            self.tableView.reloadData()
        }
    }
}

extension QLDebugViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        return 100
    }
}
