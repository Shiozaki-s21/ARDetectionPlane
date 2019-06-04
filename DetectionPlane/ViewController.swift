//
//  ViewController.swift
//  DetectionPlane
//
//  Created by SubaruShiozaki on 2019-06-04.
//  Copyright © 2019 Kazuya Takahashi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

// ARSCNViewDelegate provide the renderer method
class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  var planes = Array<Plane>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    // デバッグ時用オプション
    // ARKitが感知しているところに「+」がいっぱい出てくるようになる
    sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    
    // もう飛行機はいらないのでコメントアウト
    // Create a new scene
    //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    // 飛行機sceneはいなくなったので、新たに初期化
    sceneView.scene = SCNScene()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    // ARKit用。平面を検知するように指定
    configuration.planeDetection = .horizontal
    // 現実の環境光に合わせてレンダリングしてくれるらしい
    configuration.isLightEstimationEnabled = true
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    // 平面を生成
    let plane = Plane(anchor: planeAnchor)
    
    // ノードを追加
    node.addChildNode(plane)
    
    // 管理用配列に追加
    planes.append(plane)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    // updateされた平面ノードと同じidのものの情報をアップデート
    for plane in planes {
      if plane.anchor.identifier == anchor.identifier,
        let planeAnchor = anchor as? ARPlaneAnchor {
        plane.update(anchor: planeAnchor)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    // updateされた平面ノードと同じidのものの情報を削除
    for (index, plane) in planes.enumerated().reversed() {
      if plane.anchor.identifier == anchor.identifier {
        planes.remove(at: index)
      }
    }
  }
  
  @IBAction func sceneViewTapped(_ recognizer: UITapGestureRecognizer) {
    
    // sceneView上のタップ箇所を取得
    let tapPoint = recognizer.location(in: sceneView)
    
    // scneView上の位置を取得
    let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
    
    guard let hitResult = results.first else { return }
    
    // 箱を生成
    let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
    let cubeNode = SCNNode(geometry: cube)
    
    // 箱の判定を追加
    let cubeShape = SCNPhysicsShape(geometry: cube, options: nil)
    cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: cubeShape)
    
    // sceneView上のタップ座標のどこに箱を出現させるかを指定
    cubeNode.position = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                       hitResult.worldTransform.columns.3.y + 0.1,
                                       hitResult.worldTransform.columns.3.z)
    
    // ノードを追加
    sceneView.scene.rootNode.addChildNode(cubeNode)
  }
  
  
}
