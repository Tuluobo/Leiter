//
//  EncryptionViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import NEKit

class EncryptionViewController: UITableViewController {

    private var encryption: CryptoAlgorithm
    private var completionAction: ((CryptoAlgorithm) -> Void)?
    
    private var dataSources = CryptoAlgorithm.allCases
    
    init(encryption: CryptoAlgorithm, completionAction: @escaping ((CryptoAlgorithm) -> Void)) {
        self.encryption = encryption
        self.completionAction = completionAction
        super.init(style: .grouped)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "加密方式"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Opt.kNormalTableViewCellIdentifierKey)
    }
}

extension EncryptionViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        encryption = dataSources[indexPath.item]
        completionAction?(encryption)
        self.navigationController?.popViewController(animated: true)
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataSources[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: Opt.kNormalTableViewCellIdentifierKey, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(cellData.rawValue)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_checkmark_circle"))
        imageView.frame.size = CGSize(width: 20, height: 20)
        cell.accessoryView = imageView
        cell.accessoryView?.isHidden = (encryption != cellData)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
