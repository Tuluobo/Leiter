//
//  HomeViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import AudioToolbox
import CocoaLumberjackSwift
import ionicons
import MJRefresh
import SnapKit
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
        topBackgroundView.backgroundColor = UIColor.baseBlueColor
        topBackgroundView.addSubview(startButton)
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(135)
            make.centerY.equalToSuperview().offset(topLayoutGuide.length * 0.5)
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
        NotificationCenter.default.addObserver(forName: Notification.Name.AddProxySuccessNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let _ = notification.userInfo?["proxy"] as? Proxy else {
                return
            }
            self?.proxyTableView.mj_header.beginRefreshing()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.CurrentProxyChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self, let userInfo = notification.userInfo as? [String: Any] else {
                return
            }
            let oldValue = userInfo[kProxyOldValueKey] as? Proxy
            let newValue = userInfo[kProxyNewValueKey] as? Proxy
            if oldValue?.rid == newValue?.rid {
                self.updateConnectingVPN()
                return
            }
            // 切换才需要更新
            if let index = self.viewModel.dataSources.index(where: { $0.rid == oldValue?.rid }),
                let cell = self.proxyTableView.cellForRow(at: IndexPath(item: index, section: 0)),
                self.proxyTableView.visibleCells.contains(cell) {
                cell.isSelected = false
            }
            if let index = self.viewModel.dataSources.index(where: { $0.rid == newValue?.rid }),
                let cell = self.proxyTableView.cellForRow(at: IndexPath(item: index, section: 0)),
                self.proxyTableView.visibleCells.contains(cell) {
                cell.isSelected = true
            }
        }
        updateConnectStatus()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ProxyServiceStatusNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            self?.updateConnectStatus()
        }
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        startButton.snp.updateConstraints { (make) in
            make.centerY.equalToSuperview().offset(topLayoutGuide.length / 3.0)
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
    private func updateConnectingVPN() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if VPNManager.shared.status == .on || VPNManager.shared.status == .connecting {
                let alertVC = UIAlertController(title: "连接中的配置已更新", message: "是否需要重新连接", preferredStyle: UIAlertControllerStyle.alert)
                alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alertVC.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak self] _ in
                    self?.reconnect()
                }))
                SVProgressHUD.dismiss()
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    private func openSelectTypeViewController() {
        self.performSegue(withIdentifier: kSelectSegueID, sender: nil)
    }
    
    private func updateConnectStatus() {
        let status = VPNManager.shared.status
        switch status {
        case .connecting:
            self.connectStatusLabel.text = "正在建立连接..."
            break
        case .on:
            self.startButton.isSelected = true
            self.connectStatusLabel.text = "已建立连接"
        case .disconnecting:
            self.connectStatusLabel.text = "正在断开连接..."
            break
        case .off:
            self.startButton.isSelected = false
            self.connectStatusLabel.text = "未连接"
        }
    }
    
    private func reconnect() {
        SVProgressHUD.show(withStatus: "生成配置中...")
        VPNManager.shared.disconnect()
        SVProgressHUD.dismiss(withDelay: 0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            VPNManager.shared.connect()
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == viewModel.dataSources.count {
            openSelectTypeViewController()
        } else {
            if #available(iOS 10.0, *) {
                let feedBack = UIImpactFeedbackGenerator(style: .medium)
                feedBack.prepare()
                feedBack.impactOccurred()
            } else {
                AudioServicesPlaySystemSound(1519)
            }
            let proxy = viewModel.dataSources[indexPath.item]
            ProxyManager.shared.currentProxy = proxy
            reconnect()
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
