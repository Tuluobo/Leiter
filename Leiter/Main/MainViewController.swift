//
//  MainViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var configTableView: UITableView!
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}

extension MainViewController: UITableViewDelegate {
    
}

