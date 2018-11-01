//
//  QLDebugViewController.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/17.
//  Copyright © 2017年 TonyHan All rights reserved.
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
        
        let nib = UINib(nibName: QLBuddhaCell.identifier(), bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: QLBuddhaCell.identifier())
        
        QueryManager.shared.fetchBuddhas(.porn_91, 1) { (buddhas, errorMessage) in
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: QLBuddhaCell.identifier()) as? QLBuddhaCell {
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
