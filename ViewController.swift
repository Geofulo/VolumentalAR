//
//  ViewController.swift
//  VolumentalAR
//
//  Created by Geovanni on 8/20/18.
//  Copyright © 2018 Geoapps. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!
    var objectNode: SCNNode!
    var planes = [SCNPlane]()
    
    var isModelInserted = false
    var isRotating = false
    var currentAngleY: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        messageLabel.layer.cornerRadius = 10
        reloadButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        reloadButton.layer.cornerRadius = 10
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.AddObjectToARScene(withGestureRecognizer:)))
        
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.MoveObjectNode(withGestureRecognizer:)))
        
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.RotateObjectNode(withGestureRecognizer:)))
        
        sceneView.addGestureRecognizer(rotateGesture)
    }
    
    @objc func AddObjectToARScene(withGestureRecognizer recognizer: UIGestureRecognizer)
    {
        if isModelInserted { return }
        
        let tapLocation = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else
        {
            print("No hit test results")
            return
        }
        
        let columns = hitTestResult.worldTransform.columns
        
        print ("Adding object...")
        
        guard let urlObject = Bundle.main.url(forResource: "left", withExtension: "obj") else {
            print("Error trying to find the model file")
            return
        }
        
        guard let modelObject = MDLAsset(url: urlObject).object(at: 0) as? MDLMesh else {
            print("Error loading the 3D object")
            return
        }
        
        objectNode = SCNNode(mdlObject: modelObject)
        objectNode.position = SCNVector3(columns.3.x, columns.3.y, columns.3.z)
        objectNode.eulerAngles.x = -.pi/2
        
        let (minVec, maxVec) = objectNode.boundingBox
        objectNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        
        sceneView.scene.rootNode.addChildNode(objectNode)
        
        messageLabel.text = "Live the AR experience!"
        
        isModelInserted = true
        sceneView.debugOptions = []
        hidePlanes()
    }
    
    @objc func MoveObjectNode(withGestureRecognizer recognizer: UIPanGestureRecognizer)
    {
        if objectNode == nil { return }
        if isRotating { return }
        
        let tapLocation = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: ARHitTestResult.ResultType.featurePoint)
        
        guard let hitTestResult = hitTestResults.first else
        {
            print("No hit test results")
            return
        }
        
        let columns = hitTestResult.worldTransform.columns
        objectNode.position = SCNVector3Make(columns.3.x, objectNode.position.y, columns.3.z)
    }
    
    @objc func RotateObjectNode(withGestureRecognizer recognizer: UIRotationGestureRecognizer)
    {
        let rotation = Float(recognizer.rotation)
        
        if recognizer.state == .changed{
            isRotating = true
            objectNode.eulerAngles.y = currentAngleY - rotation
        }
        
        if(recognizer.state == .ended) {
            currentAngleY = objectNode.eulerAngles.y
            isRotating = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startARSession()
    }
    
    func startARSession(){
        
        sceneView.debugOptions = [SCNDebugOptions.showBoundingBoxes, ARSCNDebugOptions.showFeaturePoints]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        //configuration.isAutoFocusEnabled = true       // iOS 11.3
        
        sceneView.session.run(configuration, options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
        
        messageLabel.text = "Find a surface and tap on it!"
    }
    
    func hidePlanes(){
        for plane in planes {
            plane.materials.first?.diffuse.contents = UIColor.clear
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func onReloadButtonPressed(_ sender: Any) {
        sceneView.session.pause()
        
        sceneView.delegate = self
        
        objectNode.removeFromParentNode()
        
        isModelInserted = false
        
        startARSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
