//
//  ViewControllerML_Ar.swift
//  AR_prueba
//
//  Created by Ivanovicx Nuñez on 10/05/24.
//

import UIKit
import ARKit
import AVKit

class ViewControllerML_Ar : UIViewController, ARSCNViewDelegate {
    
    // Scene
    @IBOutlet weak var sceneView: ARSCNView!
    let bubbleDepth : Float = 0.01 // The depht of 3D Text
    var latestPrediction : String = "..." // A variable containing the latest CoreML prediction
    
    // Core ML
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A serial queue
    
    // Voice
    var synthetizer = AVSpeechSynthesizer()
    
    var timer: Timer?
    
    var totalMoney : Double = 0.0
    
    var speaker : Bool = true
    
    @IBOutlet weak var buttonSpeaker: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's
        sceneView.delegate = self
        
        // Iniciar temporizador para llamar a handleTap cada 5 segundos
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.handleTap(gestureRecognize:)), userInfo: nil, repeats: true)
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Enable Default Lighting - makes the 3D text a bit popier
        sceneView.autoenablesDefaultLighting = true
        
        // Tap gesture Recognizer --------
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        
        view.addGestureRecognizer(tapGesture)
        
        // Set up Vision Model
        guard let selectedModel = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Couldn't load model") }
            
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]
        
        loopCoreMLUpdate()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        // Detener el temporizador al salir de la vista
        timer?.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func rendered( _ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            
        }
    }
    
    
    @IBAction func buttonRestart(_ sender: UIButton) {
        // Remove every node in the Scene (AR)
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        totalMoney = 0.0
    }
    
    
    @IBAction func buttonSpeaker(_ sender: UIButton) {
        
        speaker.toggle()
        
        if speaker {
            buttonSpeaker.setImage(UIImage(systemName: "volume.slash.fill"), for: .normal)
        } else {
            buttonSpeaker.setImage(UIImage(systemName: "volume.3.fill"), for: .normal)
        }
    }
    
    
    @objc func handleTap ( gestureRecognize: UITapGestureRecognizer ) {
        // Hit test : Real world
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY )
        
        let arHitTestResults : [ARHitTestResult ] = sceneView.hitTest(screenCentre, types: [ .featurePoint ])
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create a 3D Text
            let node : SCNNode = createNewBubbleParentNode( latestPrediction )
            sceneView.scene.rootNode.addChildNode( node )
            node.position = worldCoord
            
            let numericValue = value(value: latestPrediction)
            totalMoney += Double( numericValue )
            
            if speaker {
                talkTotal()
            }
            
            
        }
    }
    
    @objc func handleTap () {
        // Eliminar los nodos existentes antes de agregar uno nuevo
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // Hit test : Real world
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY )
        
        let arHitTestResults : [ARHitTestResult ] = sceneView.hitTest(screenCentre, types: [ .featurePoint ])
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create a 3D Text
            let node : SCNNode = createNewBubbleParentNode( latestPrediction )
            sceneView.scene.rootNode.addChildNode( node )
            node.position = worldCoord
        }
    }
    
    func createNewBubbleParentNode ( _ text : String ) -> SCNNode {
        
        // Text Billboard Constraint
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // Bubble - text
        let bubble = SCNText( string: text, extrusionDepth: CGFloat( bubbleDepth ) )
        var font = UIFont( name: "Futura", size: 0.15 )
        font = font?.withTraits( traits: .traitBold )
        
        bubble.font = font
        bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        bubble.chamferRadius = CGFloat( bubbleDepth )
        
        // Bubble Node
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode( geometry: bubble )
        
        // centre node - to centre-bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2, minBound.y, bubbleDepth / 2)
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        // Centre point node
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode( geometry: sphere )
        
        // Bubble parent node
        let bubbleParentNode = SCNNode()
        bubbleParentNode.addChildNode(bubbleNode)
        bubbleParentNode.addChildNode(sphereNode)
        bubbleParentNode.constraints = [billboardConstraint]
        
        return bubbleParentNode
    }
    
    func loopCoreMLUpdate () {
        dispatchQueueML.async {
            self.updateCoreML()
            self.loopCoreMLUpdate()
        }
    }
    
    func classificationCompleteHandler( request: VNRequest, error: Error? ) {
        // Catch errors
        if error != nil {
            print( "Error: " + (error?.localizedDescription)! )
            return
        }
        
        guard let observations = request.results else {
            print("Sin resultados")
            return
        }
        
        // Get classifications
        let classifications = observations[0...1]
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))"})
            .joined( separator: "\n")
        
        DispatchQueue.main.async {
            // Print classifications
            print(classifications)
            print("--")
            
            // Display Debug Text on screen
            var debugText:String = ""
            debugText += classifications
//            self.debugTextView.text = debugText
            
            // Store the latest prediction
            var objectName:String = "…"
            objectName = classifications.components(separatedBy: "-")[0]
            objectName = objectName.components(separatedBy: ",")[0]
            self.latestPrediction = objectName
            
//            self.handleTap()
        }
    }
    
    func updateCoreML () {
        
        // Get camera image as RGB
        let pixbuff : CVPixelBuffer? = ( sceneView.session.currentFrame?.capturedImage )
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        
        // Prepare CoreML / Vision request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func talkTotal ( ) {
        
        let utterance = AVSpeechUtterance(string: "\( totalMoney ) pesos")
        utterance.rate = 0.50
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "es_MX")
        synthetizer.speak(utterance)
        
    }
    
    func value ( value: String ) -> Int {
        
        let pattern = "^(\\d+)_pesos?_MXN$"
           
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        // Search for coincidences
        if let match = regex?.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) {
            if let range = Range(match.range(at: 1), in: value) {
                let numberString = String(value[range])
                return Int(numberString) ?? 0
            }
        }
        
        return 0
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
