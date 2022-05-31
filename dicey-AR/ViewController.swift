//
//  ViewController.swift
//  dicey-AR
//
//  Created by Rafael Fernandez on 5/30/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func trashPressed(_ sender: UIBarButtonItem) {
        deleteDice()
    }
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions =  [ARSCNDebugOptions.showFeaturePoints]
        //        // Set the view's delegate
        sceneView.delegate = self
        //
        //        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //        let sphere = SCNSphere(radius: 0.2)
        //        // Set the scene to the view
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIImage(named: "art.scnassets/2k_mars.jpeg")
        //        sphere.materials = [material]
        //        let node = SCNNode()
        //        node.position = SCNVector3(0, 0.1, -0.5)
        //        node.geometry = sphere
        //        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        //        let diceScene = SCNScene(named: "art.scnassets/dice.scn")!
        //
        //
        //        let diceNode = diceScene.rootNode.childNode(withName: "dice", recursively: true)
        //
        //        diceNode?.position = SCNVector3(0, 0, -0.7)
        //        diceNode?.scale = SCNVector3(0.01, 0.01, 0.01)
        //        sceneView.scene.rootNode.addChildNode(diceNode ?? SCNNode())
        
        
    }
    
    @IBAction func rollPressed(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            // anchors are found all over -> need to make it plane anchor
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            // assign material
            plane.materials = [gridMaterial]
            // build geometry when anchor found
            planeNode.geometry = plane
            // insert root node
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = results.first {
                print("touched plane")
                let diceScene = SCNScene(named: "art.scnassets/dice.scn")!
                let diceNode = diceScene.rootNode.childNode(withName: "dice", recursively: true)
                diceNode?.position = SCNVector3(
                    x: hitResults.worldTransform.columns.3.x ,
                    y: hitResults.worldTransform.columns.3.y,
                    z: hitResults.worldTransform.columns.3.z)
                diceNode?.scale = SCNVector3(0.01, 0.01, 0.01)
                
                diceArray.append(diceNode ?? SCNNode())
                
                sceneView.scene.rootNode.addChildNode(diceNode ?? SCNNode())

            } else {
                print("TOUCHED SOMEWHERE ELSE")
            }
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func deleteDice() {
        for dice in diceArray {
            dice.removeFromParentNode()
        }
    }
    
    func roll(dice: SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y:0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
}
