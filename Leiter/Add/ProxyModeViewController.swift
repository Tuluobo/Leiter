//
//  ProxyModeViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SnapKit

class ProxyModeViewController: UITableViewController {

    private var proxyMode: ProxyMode
    private var completionAction: ((ProxyMode) -> Void)?
    private let dataSources = ProxyMode.allCases
    
    init(proxyMode: ProxyMode, completionAction: @escaping ((ProxyMode) -> Void)) {
        self.proxyMode = proxyMode
        self.completionAction = completionAction
        super.init(style: .grouped)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "代理模式"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Opt.kNormalTableViewCellIdentifierKey)
    }
}

extension ProxyModeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellProxy = dataSources[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: Opt.kNormalTableViewCellIdentifierKey, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(cellProxy.description)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_checkmark_circle"))
        imageView.frame.size = CGSize(width: 20, height: 20)
        cell.accessoryView = imageView
        cell.accessoryView?.isHidden = (proxyMode != cellProxy)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        proxyMode = dataSources[indexPath.item]
        completionAction?(proxyMode)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
