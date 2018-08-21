//
//  MySceneSessionDelegate.swift
//  VolumentalAR
//
//  Created by Geovanni on 8/20/18.
//  Copyright © 2018 Geoapps. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import UIKit
import SceneKit.ModelIO

extension ViewController : ARSCNViewDelegate
{
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera)
    {
        print ("Camera state: \(camera.trackingState)")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if isModelInserted { return }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print ("Adding plane...")
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.materials.first?.diffuse.contents = UIColor(red: 0.376, green: 0.447, blue: 0.494, alpha: 0.5)
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x), 0.0, CGFloat(planeAnchor.center.z))
        planeNode.eulerAngles.x = -.pi/2
        node.addChildNode(planeNode)
        
        planes.append(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x), 0.0, CGFloat(planeAnchor.center.z))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        guard let index = planes.index(of: plane) else { return }
        
        planes.remove(at: index)
    }
}
