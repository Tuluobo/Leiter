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

class HomeViewController: UIViewController {

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var routeTableView: UITableView!
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
        
        routeTableView.delegate = self
        routeTableView.dataSource = viewModel
        routeTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.viewModel.refresh()
            self?.routeTableView.reloadData()
            self?.routeTableView.mj_header.endRefreshing()
        })
        routeTableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Actions

    @objc private func clickedStartbtn(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        // TODO:
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

