//
//  ProxyViewCell.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

class ProxyViewCell: UITableViewCell, Identifiable {

    var clickedDetailAction: (() -> Void)?
    var proxy: Proxy? {
        didSet {
            updateUIs()
        }
    }
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var tapView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        tapView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapDetailImageView))
        tapView.addGestureRecognizer(gesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImageView.image = nil
        detailImageView.image = nil
        titleLabel.text = nil
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.black
    }
    
    override var isSelected: Bool {
        didSet {
            checkImageView.image = isSelected ? #imageLiteral(resourceName: "ic_checkmark") : nil
        }
    }

    private func updateUIs() {
        guard let proxy = proxy else {
            // 最后一行 增加
            titleLabel.text = "新增线路"
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            titleLabel.textColor = UIColor.baseBlueColor
            detailImageView.image = #imageLiteral(resourceName: "ic_ios_add")
            tapView.isHidden = true
            clickedDetailAction = nil
            return
        }
        tapView.isHidden = false
        // 正常显示
        titleLabel?.text = proxy.identifier ?? "\(proxy.server):\(proxy.port)"
        detailImageView.image = #imageLiteral(resourceName: "ic_information")
    }
    
    @objc private func tapDetailImageView() {
        clickedDetailAction?()
    }
}
