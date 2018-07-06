//
//  HomeViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import ionicons
import SnapKit
import MJRefresh
import CocoaLumberjackSwift
import SVProgressHUD

private let kSelectSegueID = "kSelectSegueID"

class HomeViewController: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AddProxySuccessNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CurrentProxyChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ProxyServiceStatusNotification, object: nil)
    }

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var proxyTableView: UITableView!
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    private let viewModel = HomeViewModel()
    
    private lazy var startButton: UIButton = {
        let btn = UIButton()
        let normalImage = IonIcons.image(withIcon: ion_power, size: 135, color: UIColor.white)
        btn.setImage(normalImage, for: .normal)
        let selectedImage = IonIcons.image(withIcon: ion_ios_checkmark_outline, size: 135, color: UIColor.white)
        btn.setImage(selectedImage, for: .selected)
        btn.setImage(selectedImage, for: [.selected, .highlighted])
        btn.addTarget(self, action: #selector(clickedStartbtn(btn:)), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBackgroundView.backgroundColor = Opt.baseBlueColor
        topBackgroundView.addSubview(startButton)
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(135)
            make.centerY.equalToSuperview().offset(self.topLayoutGuide.length / 2.0)
        }
        viewModel.delegate = self
        proxyTableView.delegate = self
        proxyTableView.dataSource = viewModel
        proxyTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.viewModel.refresh()
            self?.proxyTableView.reloadData()
            self?.proxyTableView.mj_header.endRefreshing()
        })
        proxyTableView.tableFooterView = UIView(frame: .zero)
        // 接收增加 通知
        NotificationCenter.default.addObserver(forName: Notification.Name.AddProxySuccessNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            self?.proxyTableView.mj_header.beginRefreshing()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.CurrentProxyChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self, let userInfo = notification.userInfo as? [String: Any] else {
                return
            }
            if let oldValue = userInfo[kProxyOldValueKey] as? Proxy,
                let index = self.viewModel.dataSources.index(where: { $0.rid == oldValue.rid }),
                let cell = self.proxyTableView.cellForRow(at: IndexPath(item: index, section: 0)),
                self.proxyTableView.visibleCells.contains(cell) {
                cell.isSelected = false
            }
            if let newValue = userInfo[kProxyNewValueKey] as? Proxy,
                let index = self.viewModel.dataSources.index(where: { $0.rid == newValue.rid }),
                let cell = self.proxyTableView.cellForRow(at: IndexPath(item: index, section: 0)),
                self.proxyTableView.visibleCells.contains(cell) {
                cell.isSelected = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ProxyServiceStatusNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            let status = VPNManager.shared.status
            switch status {
            case .connecting:
                self?.connectStatusLabel.text = "正在建立连接..."
                break
            case .on:
                self?.startButton.isSelected = true
                self?.connectStatusLabel.text = "已建立连接"
            case .disconnecting:
                self?.connectStatusLabel.text = "正在断开连接..."
                break
            case .off:
                self?.startButton.isSelected = false
                self?.connectStatusLabel.text = "未连接"
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func clickedAddBtn(_ sender: UIBarButtonItem) {
        openSelectTypeViewController()
    }
    
    @objc private func clickedStartbtn(btn: UIButton) {
        if !btn.isSelected {
            VPNManager.shared.connect()
        } else {
            VPNManager.shared.disconnect()
        }
    }
    
    // MARK: - Private
    private func openSelectTypeViewController() {
        self.performSegue(withIdentifier: kSelectSegueID, sender: nil)
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == viewModel.dataSources.count {
            openSelectTypeViewController()
        } else {
            let proxy = viewModel.dataSources[indexPath.item]
            SVProgressHUD.show(withStatus: "生成配置中...")
            ProxyManager.shared.currentProxy = proxy
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                VPNManager.shared.disconnect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    SVProgressHUD.dismiss()
                    VPNManager.shared.connect()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func openDetailConfiguration(proxy: Proxy) {
        var editVC = UIStoryboard(name: proxy.type.rawValue, bundle: nil).instantiateInitialViewController() as? EditProxyProtocol&UIViewController
        editVC?.proxy = proxy
        if let vc = editVC {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            DDLogWarn("Edit VC open Error!!!")
        }
    }
}
