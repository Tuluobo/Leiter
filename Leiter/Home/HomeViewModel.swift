//
//  HomeViewModel.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import ionicons

class HomeViewModel: NSObject {
    
    private(set) var selectedProxy: Proxy?
    private(set) var dataSources = [Proxy]()
    
    override init() {
        super.init()
        refresh()
    }
    
    func refresh() {
       let dataSources = ProxyManager.shared.all()
        // FIX:
        // 选择 selected
        // 
        self.dataSources = dataSources
    }
}

extension HomeViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count + 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item < dataSources.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let proxy = dataSources[indexPath.item]
            if ProxyManager.shared.delete(proxy) {
                dataSources.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProxyViewCell.identifier, for: indexPath) as? ProxyViewCell else {
            return UITableViewCell()
        }
        if indexPath.item == dataSources.count {
            // 最后一行 增加
            cell.titleLabel?.text = "新增线路"
            cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
            cell.titleLabel.textColor = Opt.baseBlueColor
            cell.detailImageView.image = #imageLiteral(resourceName: "ic_ios_add")
        } else {
            // 正常显示
            let proxy = dataSources[indexPath.item]
            cell.titleLabel?.text = proxy.identifier ?? "\(proxy.server):\(proxy.port)"
            cell.detailImageView.image = #imageLiteral(resourceName: "ic_information")
            if let select = selectedProxy, select.rid == proxy.rid {
                cell.checkImageView.image = #imageLiteral(resourceName: "ic_checkmark")
            }
        }
        return cell
    }
    
}
