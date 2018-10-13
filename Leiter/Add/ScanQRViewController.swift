//
//  ScanQRViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import AVKit
import ionicons
import SVProgressHUD
import SGQRCode

class ScanQRViewController: UIViewController {
    
    deinit {
        removeScanningView()
    }
    
    private lazy var scanView: SGQRCodeScanView = {
        return SGQRCodeScanView(frame: self.view.bounds)
    }()
    private lazy var obtain: SGQRCodeObtain = {
        let ob = SGQRCodeObtain()
        return ob
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupQRCodeScan()
        view.addSubview(scanView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        obtain.startRunningWith(before: nil, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scanView.addTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scanView.removeTimer()
        obtain.stopRunning()
    }
    
    fileprivate func handleQRData(string: String?) {
        guard ProxyManager.shared.saveQRcode(with: string) else {
            SVProgressHUD.showError(withStatus: "没有识别到相关配置信息，请重新扫描...")
            return
        }
        NotificationCenter.default.post(name: Notification.Name.AddProxySuccessNotification, object: nil)
        SVProgressHUD.showSuccess(withStatus: "添加成功")
    }
}

extension ScanQRViewController {
    
    private func setupQRCodeScan() {
        let configure = SGQRCodeObtainConfigure()
        obtain.establishQRCodeObtainScan(with: self, configure: configure)
        obtain.setBlockWithQRCodeObtainScanResult { [weak self] (obtain, result) in
            guard let `self` = self else { return }
            obtain?.stopRunning()
            obtain?.playSoundName("SGQRCode.bundle/sound.caf")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.handleQRData(string: result)
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    private func removeScanningView() {
        self.scanView.removeTimer()
        self.scanView.removeFromSuperview()
    }
    
}

extension ScanQRViewController {
    
    @IBAction func rightBarButtonItenAction(button: UIBarButtonItem) {
        obtain.establishAuthorizationQRCodeObtainAlbum(with: nil)
        if obtain.isPHAuthorization {
            scanView.removeTimer()
        }
        obtain.setBlockWithQRCodeObtainAlbumDidCancelImagePickerController { [weak self] (_) in
            guard let `self` = self else { return }
            self.view.addSubview(self.scanView)
        }
        obtain.setBlockWithQRCodeObtainAlbumResult { (obtain, result) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.handleQRData(string: result)
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}
