//
//  SwitchCell.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/8.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pingfangRegular(15)
        return label
    }()
    lazy var switchControl: UISwitch = {
        let control = UISwitch()
        return control
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(switchControl)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        switchControl.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-16)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        switchControl.isOn = false
    }
}
