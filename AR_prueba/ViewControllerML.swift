//
//  ViewControllerML.swift
//  AR_prueba
//
//  Created by Ivanovicx Nuñez on 06/05/24.
//

import UIKit
import AVKit
import Vision

class ViewControllerML: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: Peso_1().model) else { return }
        let request = VNCoreMLRequest(model: model)
            { (finishedReq, err) in
                // perhaps check the error
                guard let results = finishedReq.results as? [VNRecognizedObjectObservation] else { return }
                
                guard let firstObservation = results.first else { return }
                        
                for observation in results {
                    for label in observation.labels {
                        print("Detected object: \(label.identifier), Confidence: \(label.confidence)")
                    }
                }
                
            }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
}

