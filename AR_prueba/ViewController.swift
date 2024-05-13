//
//  ViewController.swift
//  AR_prueba
//
//  Created by Ivanovicx Nuñez on 30/04/24.
//

/*
 
 Notas:
 
    - Implementar un JSON para limpiar las etiquetas
        "1_peso_MXN": "1 peso"
 
 */

import UIKit
import SceneKit
import ARKit
import CoreML
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Did Load")
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        configuration.maximumNumberOfTrackedImages = 100
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "billetes", bundle: nil) else {
            fatalError("Couldn't load tracing images")
        }
        
        configuration.trackingImages = trackingImages 

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        
//        super.viewWillAppear(animated)
//        
//        
//        print("Will Appear")
//        
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        
//        // Enable horizontal plane detection
//        configuration.planeDetection = [.horizontal]
//        
//        // Run the view's session
//        sceneView.session.run(configuration)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        print("Will Disappear")
//        
//        // Pause the view's session
//        sceneView.session.pause()
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return nil
        }
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        return node
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//       guard let imageAnchor = anchor as? ARImageAnchor else { return }
//       
//        
//        print("Renderer")
//        
//       // Create a plane geometry to visualize the detected image
//       let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
//                            height: imageAnchor.referenceImage.physicalSize.height)
//       plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.5)
//       
//       // Create a plane node and add it to the scene
//       let planeNode = SCNNode(geometry: plane)
//       planeNode.eulerAngles.x = -.pi / 2
//       node.addChildNode(planeNode)
//       }
//    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        
//        
//        print("Session")
//        
//        let imageBuffer = frame.capturedImage
//        
//        let ciImage = CIImage(cvImageBuffer: imageBuffer)
//        
//        let handler = VNImageRequestHandler(ciImage: ciImage)
//        
//        do {
//            try handler.perform([detectionRequest])
//        } catch {
//            print("Failed to perform detection: \(error.localizedDescription)")
//        }
//    }
//    
//    private func processDetections(for request: VNRequest, error: Error?) {
//        guard let results = request.results else {
//            print("Unable to detect anything.\n\(error!.localizedDescription)")
//            return
//        }
//        
//        
//        print("Process Detention")
//        
//        let detections = results as! [VNRecognizedObjectObservation]
//        // Handle the detected objects here
//        // For example, you can add 3D objects to the scene based on the detected objects
//        for detection in detections {
//            // Retrieve the identifier of the detected object
//            let identifier = detection.labels[0].identifier
//            print("Detected object: \(identifier)")
//        }
//    }

}
