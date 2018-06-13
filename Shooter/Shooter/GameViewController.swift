//
//  GameViewController.swift
//  Shooter
//
//  Created by Starblo Hong on 11/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import Foundation
import CoreFoundation
import os
import UIKit
import ARKit

class GameViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var mode : Mode = Mode.mode1
    
    //TODO: var mode
    var isTimerRunning =  false;
    var timer = Timer();
    
    var paused = false;
    var gameInfo = GameInfo();
    var loadFromLocalFile = true;
    
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var timerButton: UIButton!

    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var optionButton: UIButton!
    
    @IBOutlet weak var musicButton: UIButton!
    
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var musicController: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        pauseView.isHidden = true;
        musicController.isHidden = true;
        
        loadFromLocalFile = UserDefaults.standard.bool(forKey: "loadFromLocalFile");
        
        //NOTE: loadFromLocalFile =》 archive
        
        //case infinity mode, gameInfo.infinityMode -> true
        //case time limiting mode, gameInfo.timeLimiting -> true
        //default number of monster is 10
        //default time limit is 60s
        
        if(loadFromLocalFile) {
            loadFromFile();
        } else {
            initMonster();
        }
        
        loadModel(animated: gameInfo.animating);
        
        addTapGestureToSceneView();
        if gameInfo.timeLimiting {
            runTimer();
        } else {
            timerButton.isHidden = true;
        }
    }
    
    func loadFromFile() {
        if let info = NSKeyedUnarchiver.unarchiveObject(withFile: GameInfo.ArchiveURL.path) as? GameInfo {
            gameInfo = info;
            scoreButton.setTitle(String(gameInfo.hitCount), for: UIControlState.normal);
            timerButton.setTitle(String(gameInfo.timeRemain), for: UIControlState.normal);
        } else {
            initMonster();
        }
    }
    
    func saveIntoLocalFile() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(gameInfo, toFile: GameInfo.ArchiveURL.path);
        if isSuccessfulSave {
            os_log("gameInfo successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save gameInfo...", log: OSLog.default, type: .error)
        }
    }
    
    func initMonster() {
        for i in 1...gameInfo.initMonsterCount {
            gameInfo.monsters.append(Monster());
        }
    }
    
    
    @IBAction func toggleMusicController(_ sender: Any) {
        musicController.isHidden = !musicController.isHidden;
    }
    
    @IBAction func toggleBgMusic(_ sender: Any) {
        musicController.isHidden = true;
        //TODO: turn on/off background music
    }
    
    
    @IBAction func toggleSoundEffect(_ sender: Any) {
        musicController.isHidden = true;
        //TODO: turn on/off sound effect
    }
    
    @IBAction func onTimerClick(_ sender: Any) {
        pauseView.isHidden = false;
        timer.invalidate();
        paused = true;
    }
    
    @IBAction func onContinueButtonClick(_ sender: Any) {
        pauseView.isHidden = true;
        paused = false;
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true);
    }
    
    func loadModel(animated: Bool = true) {
        for m in gameInfo.monsters {
            if m.dead {
                continue;
            }
            addModel(m, animated);
        }
    }
    
    func addModel(_ m: Monster, _ animated: Bool) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0);
        
        let boxNode = SCNNode();
        boxNode.geometry = box;
        boxNode.position = SCNVector3(m.initPostion.x, m.initPostion.y, m.initPostion.z);
        
        boxNode.name = m.id; //attach node with m
        
        if(animated) {
            let rotationAnimation = CABasicAnimation(keyPath:"rotation");
            rotationAnimation.toValue = NSValue(scnVector4:SCNVector4Make(0, 1, 0, Float( Double.pi * 2)));
            rotationAnimation.duration = 4.0;
            rotationAnimation.repeatCount = .infinity;
            
            let animation = CABasicAnimation(keyPath: "position");
            animation.toValue = NSValue(scnVector3: SCNVector3Make(m.animationPostion.x, m.animationPostion.y, m.animationPostion.z));
            animation.duration = 5.0;
            animation.autoreverses = true;
            animation.repeatCount = .infinity
            
            
            boxNode.addAnimation(animation, forKey: nil);
            boxNode.addAnimation(rotationAnimation, forKey:nil);
        }
        
        sceneView.scene.rootNode.addChildNode(boxNode);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let config = ARWorldTrackingConfiguration();
        sceneView.session.run(config);
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        sceneView.session.pause();
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func onQuitButtonClick(_ sender: Any) {
        //TODO: navigate to next view
        //NOTE: forKey
        UserDefaults.standard.set(true, forKey: "LOCAL_KEY");
        saveIntoLocalFile();
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true);
    }
    
    @objc func updateTime() {
        if(gameInfo.timeRemain == 0 && gameInfo.timeLimiting) {
            if(mode == Mode.mode1) {
                //infinity mode
                //NOTE: forKey
                UserDefaults.standard.set(gameInfo.hitCount, forKey: "MODE_1_NEW_SCORE");
            } else {
                //NOTE: forKey
                UserDefaults.standard.set(gameInfo.hitCount, forKey: "MODE_2_NEW_SCORE");
            }
            //TODO: navigate
            return;
        }
        gameInfo.timeRemain = gameInfo.timeRemain - 1;
        timerButton.setTitle(String(gameInfo.timeRemain), for: UIControlState.normal);
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        musicController.isHidden = true;
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            return
        }
        if paused {
            return;
        }
        
        node.removeFromParentNode();
        for i in 0...(gameInfo.monsters.count-1) {
            if(gameInfo.monsters[i].id == node.name) {
                gameInfo.monsters[i].dead = true;
            }
        }
        
        incrementHitCount();
        playSoundEffect();
        
        if(mode == Mode.mode1) {
            //case infinity mode
            randomAddNode();
        }
        
        //for mode2
        if(gameInfo.timeLimiting && gameInfo.hitCount == gameInfo.initMonsterCount) {
            //TODO: navigate
        }
    }
    
    func randomAddNode() {
        let m = Monster();
        m.id = String(gameInfo.monsters.count);
        addModel(m, gameInfo.animating);
        gameInfo.initMonsterCount = gameInfo.initMonsterCount + 1;
    }
    
    func playSoundEffect() {
        //TODO:
    }
    
    func playBgMusic() {
        //TODO:
    }
    
    func incrementHitCount() {
        gameInfo.hitCount = gameInfo.hitCount + 1;
        scoreButton.setTitle(String(gameInfo.hitCount), for: UIControlState.normal);
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3;
        return float3(translation.x, translation.y, translation.z);
    }
}
