//
//  TextFieldCell.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/8.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SnapKit

class TextFieldCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pingfangRegular(15)
        return label
    }()
    lazy var textField: UITextField = {
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 15)
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addSubview(titleLabel)
        addSubview(textField)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        textField.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-16)
        }
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        textField.text = nil
    }
}
