//
//  CameraVC.swift
//  Vision
//
//  Created by Marlon Avery on 4/5/18.
//  Copyright © 2018 Marlon Avery. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum flashState {
    case off
    case on
}

class CameraVC: UIViewController, UIImagePickerControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var flashControlState: flashState = .off
    
    var model = SqueezeNet()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureImageView: RoundedShadowImageView!
    @IBOutlet weak var flashControlBtn: UIButton!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
        spinner.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView(sender:)))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
                
                cameraOutput = AVCapturePhotoOutput()
                
                if captureSession.canAddOutput(cameraOutput) == true {
                    captureSession.addOutput(cameraOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    
                    cameraView.layer.addSubLayer(previewLayer)
                    cameraView.addGestureRecognizer(tap)
                    captureSession?.startRunning()
                }
            }
        } catch {
            print(error)
        }
    }
    
    @objc func didTapCameraView(sender: UITapGestureRecognizer) {
        self.cameraView.isUserInteractionEnabled = false
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Oops! An error occurred: \(error.localizedDescription)")
        } else {
            guard let photoData = photo.fileDataRepresentation() else { return }
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completetionHandler: myResultsMethod)
                let handler = VNImageRequestHandler(data: photoData)
                try? handler.perform([request])
            } catch {
                print(error)
            }
            
            let image = UIImage(data: photoData)
            self.captureImageView.image = image!
            
            cameraView.isUserInteractionEnabled = true
            spinner.isHidden = true
            spinner.stopAnimating()
        }
    }
    
    
    @IBAction func flasgControlBtnWasPressed(_ sender: Any) {
        switch flashControlState {
        case.off:
            flashControlBtn.setTitle("Flash On", for: .normal)
            flashControlState = .on
        case.on:
            flashControlBtn.setTitle("Flash Off", for: .normal)
            flashControlState = .off
        }
    }
}




























