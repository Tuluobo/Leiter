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

class ScanQRViewController: UIViewController {
    
    private var height: CGFloat!
    
    @IBOutlet weak var scanLineImageView: UIImageView!
    @IBOutlet weak var scanLineTopCons: NSLayoutConstraint!
    @IBOutlet weak var scanLineHeightCons: NSLayoutConstraint!
    
    // MARK: - 懒加载
    
    private lazy var input: AVCaptureDeviceInput? = {
        guard let capture = AVCaptureDevice.default(for: .video) else { return nil }
        return try? AVCaptureDeviceInput(device: capture)
    }()
    private lazy var session: AVCaptureSession = AVCaptureSession()
    private lazy var output: AVCaptureMetadataOutput =  {
        let op = AVCaptureMetadataOutput()
        let viewFrame = self.view.frame
        let y = ((viewFrame.width - self.height)/2) / viewFrame.width
        let x = ((viewFrame.height - self.height)/2 - 20) / viewFrame.height
        let width = self.height / viewFrame.size.height
        let height = self.height / viewFrame.size.width

        op.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
        return op
    }()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        AVCaptureVideoPreviewLayer(session: self.session)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TrackerManager.shared.trace(event: "scan_enter")
        
        height = scanLineHeightCons.constant
        let image = IonIcons.image(withIcon: ion_images, size: 32, color: UIColor.white)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(openGallery))
        scanQRCode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanLineTopCons.constant = 0 - scanLineHeightCons.constant
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 3.0) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanLineTopCons.constant = self.scanLineHeightCons.constant
            self.view.layoutIfNeeded()
        }
    }
    
    private func scanQRCode() {
        guard let input = input else { return }
        
        if !session.canAddInput(input), !session.canAddOutput(output) { return }
        session.addInput(input)
        session.addOutput(output)
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        // start
        session.startRunning()
    }
    
    @objc func openGallery() {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true, completion: nil)
    }
    
    fileprivate func handleQRData(string: String?) {
        guard ProxyManager.shared.saveQRcode(with: string) else {
            SVProgressHUD.showError(withStatus: "没有识别到相关配置信息，请重新扫描...")
            return
        }
        session.stopRunning()
        NotificationCenter.default.post(name: NSNotification.Name.AddProxySuccessNotification, object: nil)
        SVProgressHUD.showSuccess(withStatus: "添加成功")
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ScanQRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: nil)
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector!.features(in: CIImage(image: image)!)
        handleQRData(string: (features.last as? CIQRCodeFeature)?.messageString)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for object in metadataObjects {
            guard let dataObject = previewLayer.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject else { return }
            switch dataObject.type {
            case .qr:
                handleQRData(string: dataObject.stringValue)
            default: break
            }
        }
    }
    
}
