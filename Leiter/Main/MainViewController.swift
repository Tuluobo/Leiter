//
//  MainViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import ionicons
import SnapKit

class MainViewController: UIViewController {

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var configTableView: UITableView!
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    private lazy var startButton: UIButton = {
        let btn = UIButton()
        let normalImage = IonIcons.image(withIcon: ion_power, size: 128, color: UIColor.white)
        btn.setImage(normalImage, for: .normal)
        let selectedImage = IonIcons.image(withIcon: ion_ios_checkmark_outline, size: 128, color: UIColor.white)
        btn.setImage(selectedImage, for: .selected)
        btn.setImage(selectedImage, for: [.selected, .highlighted])
        btn.addTarget(self, action: #selector(clickedStartbtn(btn:)), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBackgroundView.addSubview(startButton)
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(128)
            make.centerY.equalToSuperview().offset(self.topLayoutGuide.length / 2.0)
        }
    }
    
    // MARK: - Actions

    @objc private func clickedStartbtn(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        // TODO:
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
}

