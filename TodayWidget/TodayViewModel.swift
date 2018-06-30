//
//  TodayViewModel.swift
//  TodayWidget
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

private let kRouteTableCellIdentifier = "kRouteTableCellIdentifier"

class TodayViewModel: NSObject {
    private var config = [String]()
}

extension TodayViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kRouteTableCellIdentifier, for: indexPath) as? TodayViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
}
