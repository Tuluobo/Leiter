//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import NotificationCenter
import TrafficPolice

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private let viewModel = TodayViewModel()
    
    @IBOutlet weak var wifiNetLabel: UILabel!
    @IBOutlet weak var wifiDownloadSpeedLabel: UILabel!
    @IBOutlet weak var wifiUploadSpeedLabel: UILabel!
    
    @IBOutlet weak var cellularDownloadSpeedLabel: UILabel!
    @IBOutlet weak var cellularUploadSpeedLabel: UILabel!
    @IBOutlet weak var showStatusLabel: UILabel!
    @IBOutlet weak var routeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        // 流量监控
        TrafficManager.shared.delegate = self
        TrafficManager.shared.start()
        // TableView
        self.routeTableView.delegate = self
        self.routeTableView.dataSource = viewModel
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width:UIScreen.main.bounds.size.width, height: 110)
        } else {
            self.preferredContentSize = CGSize(width:UIScreen.main.bounds.size.width, height: 400)
        }
    }
    
    @IBAction func clickConnectSwitch(_ sender: UISwitch) {
        showStatusLabel.text = sender.isOn ? "On" : "Off"
    }
}

extension TodayViewController: TrafficManagerDelegate {
    
    func post(summary: TrafficSummary) {
        let wifi = summary.wifi.speed
        self.wifiDownloadSpeedLabel.text = "D: \(wifi.received.unitString)"
        self.wifiUploadSpeedLabel.text = "U: \(wifi.sent.unitString)"

        let wwan = summary.wwan.speed
        self.cellularDownloadSpeedLabel.text = "D: \(wwan.received.unitString)"
        self.cellularUploadSpeedLabel.text = "U: \(wwan.sent.unitString)"
    }
}

extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
