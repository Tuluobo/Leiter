//
//  AboutViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import MessageUI
import SnapKit
import SPBaseKit
import StoreKit
import VTAcknowledgementsViewController

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var reviewCell: UITableViewCell!
    @IBOutlet weak var acknowledgeCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于 Leiter"
        versionLabel.text = "V\(Opt.mainVersion) Build \(Opt.buildVersion)"
    }
}

extension AboutViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 160
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
        label.textColor = UIColor.baseBlueColor
        label.text = (Bundle.main.infoDictionary?["CFBundleName"] as? String)?.uppercased()
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
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
        case feedbackCell:
            makeFeedback()
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
    
    private func makeFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let picker = MFMailComposeViewController()
            picker.navigationBar.tintColor = UIColor.white
            picker.mailComposeDelegate = self
            // 添加主题
            picker.setSubject("Leiter FeedBack")
            // 添加收件人
            let toRecipients = ["admin@tuluobo.com"]
            picker.setToRecipients(toRecipients)
            // 直接在HTML代码中写入图片的地址
            let modelName = UIDevice.current.modelName
            let osVersion = UIDevice.current.systemVersion
            let emailBody = "请在下面输入你的反馈和意见：\n\n\n\n 设备和软件信息：\n\(modelName) iOS:\(osVersion) Leiter-\(Opt.mainVersion) Build(\(Opt.buildVersion))"
            picker.setMessageBody(emailBody, isHTML: false)
            
            self.present(picker, animated: true, completion: nil)
        }
        
    }
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
        var msg: String
        switch result {
        case .failed:
            msg = "发送失败，请稍后再试。"
        case .sent:
            msg = "发送成功。"
        case .cancelled:
            msg = "已取消发送"
        case .saved:
            msg = "已保存到草稿箱"
        }
        let alertVC = UIAlertController(title: "Feedback Message", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}
