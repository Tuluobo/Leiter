//
//  BaseNavigationController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SPBaseKit

protocol SegueProtocol {
    static var segueIdentifier: String { get }
}

extension SegueProtocol {
    static var segueIdentifier: String {
        return "\(self)SegueID"
    }
}

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage.image(with: Opt.baseBlueColor), for: .any, barMetrics: .default)
        navigationBar.shadowImage = UIImage()
    }
}
