//
//  HomeViewModel.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import ionicons

protocol HomeViewModelDelegate: class {
    func openDetailConfiguration(proxy: Proxy)
}

class HomeViewModel: NSObject {
    
    weak var delegate: HomeViewModelDelegate?
    
    private(set) var dataSources = [Proxy]()
    
    override init() {
        super.init()
        refresh()
    }
    
    func refresh() {
        self.dataSources = ProxyManager.shared.all()
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
        cell.isSelected = false
        if indexPath.item == dataSources.count {
            cell.proxy = nil
        } else {
            let proxy = dataSources[indexPath.item]
            cell.proxy = proxy
            if let select = ProxyManager.shared.currentProxy, select.rid == proxy.rid {
                cell.isSelected = true
            }
            cell.clickedDetailAction = { [weak self] in
                self?.delegate?.openDetailConfiguration(proxy: proxy)
            }
        }
        return cell
    }
    
}
