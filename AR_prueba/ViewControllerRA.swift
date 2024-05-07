//
//  ViewControllerRA.swift
//  AR_prueba
//
//  Created by Ivanovicx Nuñez on 06/05/24.
//

import UIKit
import SceneKit
import ARKit
import CoreML
import Vision

class ViewControllerRA: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    lazy var detectionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: Peso_1().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processDetections(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable the detection of horizontal planes
        configuration.planeDetection = [.horizontal]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let imageBuffer = frame.capturedImage
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([detectionRequest])
        } catch {
            print("Failed to perform detection: \(error.localizedDescription)")
        }
    }
    
    private func processDetections(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("Unable to detect anything.\n\(error!.localizedDescription)")
            return
        }
        
        let detections = results as! [VNRecognizedObjectObservation]
        for detection in detections {
            let identifier = detection.labels[0].identifier
            print("Detected object: \(identifier)")
        }
    }
}
