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
    
    private(set) var selectedRoute: Route?
    private var dataSources = [Route]()
    
    override init() {
        super.init()
        refresh()
    }
    
    func refresh() {
       let dataSources = RouteManager.shared.all()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RouteViewCell.identifier, for: indexPath) as? RouteViewCell else {
            return UITableViewCell()
        }
        if indexPath.item == dataSources.count {
            // 最后一行 增加
            cell.titleLabel?.text = "新增线路"
            cell.detailImageView.image = #imageLiteral(resourceName: "ic_ios_add")
        } else {
            // 正常显示
            let route = dataSources[indexPath.item]
            cell.titleLabel?.text = route.identifier ?? "\(route.server):\(route.port)"
            cell.detailImageView.image = #imageLiteral(resourceName: "ic_information")
            if let select = selectedRoute, select.rid == route.rid {
                cell.checkImageView.image = #imageLiteral(resourceName: "ic_checkmark")
            }
        }
        return cell
    }
    
}
