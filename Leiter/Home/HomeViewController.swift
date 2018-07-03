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

private let kSelectSegueID = "kSelectSegueID"

class HomeViewController: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        proxyTableView.delegate = self
        proxyTableView.dataSource = viewModel
        proxyTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.viewModel.refresh()
            self?.proxyTableView.reloadData()
            self?.proxyTableView.mj_header.endRefreshing()
        })
        proxyTableView.tableFooterView = UIView(frame: .zero)
        // 接收增加 通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AddProxySuccessNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            self?.proxyTableView.mj_header.beginRefreshing()
        }
    }
    
    // MARK: - Actions
    @IBAction func clickedAddBtn(_ sender: UIBarButtonItem) {
        openSelectTypeViewController()
    }
    
    @objc private func clickedStartbtn(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        // TODO:
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
            var editVC = UIStoryboard(name: proxy.type.rawValue, bundle: nil).instantiateInitialViewController() as? EditProxyProtocol&UIViewController
            editVC?.proxy = proxy
            if let vc = editVC {
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                DDLogWarn("Edit VC open Error!!!")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
