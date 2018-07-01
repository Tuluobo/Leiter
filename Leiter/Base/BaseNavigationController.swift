//
//  BaseNavigationController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SPBaseKit

//MARK: - Identifiable

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        return "\(self)"
    }
}

// MARK: - BaseNavigationController

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage.image(with: Opt.baseBlueColor), for: .any, barMetrics: .default)
        navigationBar.shadowImage = UIImage()
    }
}
