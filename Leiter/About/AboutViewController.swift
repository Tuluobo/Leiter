//
//  AboutViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import StoreKit
import VTAcknowledgementsViewController
import SnapKit

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var reviewCell: UITableViewCell!
    @IBOutlet weak var acknowledgeCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于 Leiter"
        let info = Bundle.main.infoDictionary
        versionLabel.text = "V\(info?["CFBundleShortVersionString"] ?? "0.0.1") Build \(info?["CFBundleVersion"] ?? 1)"
    }
}

extension AboutViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 150
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        let view = UIView()
        
        let imageView = UIImageView(image: UIImage(named: "app-icon"))
        view.addSubview(imageView)
        let label = UILabel()
        view.addSubview(label)
        label.textAlignment = .center
        label.textColor = Opt.baseBlueColor
        label.text = (Bundle.main.infoDictionary?["CFBundleName"] as? String)?.uppercased()
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "@Copyright 2018"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.isSelected = false
        switch cell {
        case reviewCell:
            review()
        case acknowledgeCell:
            guard let viewController = VTAcknowledgementsViewController.acknowledgementsViewController() else { return }
            self.navigationController?.pushViewController(viewController, animated: true)
        default: break
        }
    }
    
    // MARK: - Private
    
    private func review() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let appStoreURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&id=1262292082"
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
}
