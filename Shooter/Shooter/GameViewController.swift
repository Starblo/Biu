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
    //IsWin: to pass it to the ResultViewController, implies whether if win or lose
    var IsWin : Bool = false
    
    var isTimerRunning =  false;
    var timer = Timer();
    
    var paused = false;
    var gameInfo = GameInfo();
    var loadFromLocalFile = true;
    
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var timerButton: UIButton!

    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var nextLevelButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    @IBOutlet weak var nextLevelView: UIView!
    
    @IBOutlet weak var musicButton: UIButton!
    
    @IBOutlet weak var monsterRemainCountLabel: UILabel!
    
    @IBOutlet weak var musicController: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        pauseView.isHidden = true;
        musicController.isHidden = true;
        nextLevelView.isHidden = true;
        self.quitButton.layer.cornerRadius = self.quitButton.bounds.height/2
        self.continueButton.layer.cornerRadius = self.continueButton.bounds.height/2
        self.nextLevelButton.layer.cornerRadius = self.nextLevelButton.bounds.height/2
        self.CancelButton.layer.cornerRadius = self.CancelButton.bounds.height/2
        
        if mode == Mode.mode1 {
            self.loadFromLocalFile = UserDefaults.standard.bool(forKey: "LoadFromLocalFile_Mode1")
            UserDefaults.standard.set(false, forKey: "LoadFromLocalFile_Mode1")
        } else {self.quitButton.layer.cornerRadius = self.quitButton.bounds.height/2
            self.loadFromLocalFile = UserDefaults.standard.bool(forKey: "LoadFromLocalFile_Mode2")
            UserDefaults.standard.set(false, forKey: "LoadFromLocalFile_Mode2")
        }
        
        //NOTE: loadFromLocalFile =》 archive
        
        //case infinity mode, gameInfo.infinityMode -> true
        //case time limiting mode, gameInfo.timeLimiting -> true
        //default number of monster is 10
        //default time limit is 60s
        
        if(self.loadFromLocalFile) {
            loadFromFile();
        } else {
            if(mode == Mode.mode2) {
                initLevel(level: 0);
            } else {
                gameInfo.totalMonsterCount = 10;
                gameInfo.timeRemain = 60;
            }
            initMonster();
        }
        loadModel(animated: gameInfo.animating);
        
        if self.mode == Mode.mode1 {
            self.monsterRemainCountLabel.text = "0"
        } else {
            self.monsterRemainCountLabel.text = String(gameInfo.totalMonsterCount - gameInfo.hitCount)
        }
        
        addTapGestureToSceneView();
        if gameInfo.timeLimiting {
            if self.mode == Mode.mode2 && self.gameInfo.IsLevelOnePassed == true {
                pauseView.isHidden = false
            } else {
                runTimer();
            }
        } else {
            timerButton.isHidden = true;
        }
        
        sceneView.autoenablesDefaultLighting = true;
        
        
 
    }

    func initLevel(level: Int) {
        self.gameInfo.timeRemainForLevelOne = self.gameInfo.timeRemain;
        self.gameInfo.animating = GameLevel.levels[level].animating;
        self.gameInfo.timeRemain = GameLevel.levels[level].timeLimit;
        self.gameInfo.totalMonsterCount += GameLevel.levels[level].monsterNum;
        print("GAMEINFO:", self.gameInfo.totalMonsterCount);
    }
    
    func loadFromFile() {
        if let info = NSKeyedUnarchiver.unarchiveObject(withFile: GameInfo.ArchiveURL.path) as? GameInfo {
            
            self.gameInfo = info;
            if(self.mode == Mode.mode2) {
                self.monsterRemainCountLabel.text = String(self.gameInfo.totalMonsterCount - self.gameInfo.hitCount)
            } else {
                self.monsterRemainCountLabel.text = String(self.gameInfo.hitCount)
            }
            self.timerButton.setTitle(String(self.gameInfo.timeRemain), for: UIControlState.normal);
        } else {
            if(self.mode == Mode.mode2) {
                initLevel(level: 0);
            } else {
                self.gameInfo.totalMonsterCount = 10;
                self.gameInfo.timeRemain = 60;
            }
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
        for _ in 1...self.gameInfo.totalMonsterCount {
            self.gameInfo.monsters.append(Monster());
        }
    }

    
    @IBAction func onNextLevelButtonClick(_ sender: UIButton) {
        nextLevelView.isHidden = true;
        self.gameInfo.currentLevel = self.gameInfo.currentLevel + 1;
        initLevel(level: self.gameInfo.currentLevel - 1);
        randomAddNode(self.gameInfo.totalMonsterCount - self.gameInfo.monsters.count);
        
        self.monsterRemainCountLabel.text = String(self.gameInfo.totalMonsterCount - self.gameInfo.hitCount)
        self.timerButton.setTitle(String(self.gameInfo.timeRemain), for: UIControlState.normal);
        
        runTimer();
    }
    
    @IBAction func toggleMusicController(_ sender: UIButton) {
        self.musicController.isHidden = !self.musicController.isHidden;
        if self.musicController.isHidden == false {
            timer.invalidate()
        } else {
            runTimer()
        }
    }
    
    @IBAction func toggleBgMusic(_ sender: UIButton) {
        MusicManager.sharedInstance.changeBackMusicState(sender)
        self.musicController.isHidden = true;
        runTimer()
    }
    
    @IBAction func toggleSoundEffect(_ sender: UIButton) {
        MusicManager.sharedInstance.changeMusicState(sender)
        self.musicController.isHidden = true;
        runTimer()
    }
    
    
    @IBAction func onTimerClick(_ sender: Any) {
        self.pauseView.isHidden = false;
        self.timer.invalidate();
        self.paused = true;
    }
    
    @IBAction func onContinueButtonClick(_ sender: Any) {
        self.pauseView.isHidden = true;
        self.paused = false;
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true);
    }
    @IBAction func onNextLevelViewQuitButtonClick(_ sender: UIButton) {
        if self.mode == Mode.mode1 {
            UserDefaults.standard.set(true, forKey: "LoadFromLocalFile_Mode1")
        } else {
                UserDefaults.standard.set(true, forKey: "LoadFromLocalFile_Mode2")
        }
        saveIntoLocalFile();
    }
    
    func loadModel(animated: Bool = true) {
        for m in self.gameInfo.monsters {
            if m.dead {
                continue;
            }
            addModel(m, animated);
        }
    }
    
    func addModel(_ m: Monster, _ animated: Bool) {
        
        let tempScene = SCNScene(named: "art.scnassets/Patrick/Patrick.obj")!
        let boxNode = tempScene.rootNode;
        boxNode.scale = SCNVector3(0.05, 0.05, 0.05);
        boxNode.position = SCNVector3(m.initPostion.x, m.initPostion.y, m.initPostion.z);
        boxNode.name = m.id; //attach node with m
        
        
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0);
//
//        let boxNode = SCNNode();
//        boxNode.geometry = box;
//        boxNode.position = SCNVector3(m.initPostion.x, m.initPostion.y, m.initPostion.z);
//
//        boxNode.name = m.id; //attach node with m
        
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
        MusicManager.sharedInstance.Loading()
        
        super.viewWillAppear(animated);
        
        let config = ARWorldTrackingConfiguration();
        sceneView.session.run(config);
        
        MusicManager.sharedInstance.playBackgroundMusic();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        sceneView.session.pause();
        
        MusicManager.sharedInstance.stopBackgroundMusic();
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func onQuitButtonClick(_ sender: Any) {
        if self.mode == Mode.mode1 {
            UserDefaults.standard.set(true, forKey: "LoadFromLocalFile_Mode1")
        } else {
            UserDefaults.standard.set(true, forKey: "LoadFromLocalFile_Mode2")
        }
        saveIntoLocalFile();
    }
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true);
    }
    
    @objc func updateTime() {
        if(self.gameInfo.timeRemain == 0 && self.gameInfo.timeLimiting) {
            if(self.mode == Mode.mode1) {
                //infinity mode
                //NOTE: forKey
                UserDefaults.standard.set(self.gameInfo.hitCount * 5, forKey: "MODE_1_NEW_SCORE");
            } else {
                //NOTE: forKey
                var score = 0
                if self.gameInfo.currentLevel == self.gameInfo.maxLevel {
                    score = GameLevel.levels[0].monsterNum + self.gameInfo.hitCount * 5 + self.gameInfo.timeRemainForLevelOne * 10
                } else {
                    score = self.gameInfo.hitCount
                }
                UserDefaults.standard.set(score, forKey: "MODE_2_NEW_SCORE");
            }
            self.timer.invalidate()
            self.performSegue(withIdentifier: "ShowResultView", sender: self)
            return;
        }
        self.gameInfo.timeRemain = self.gameInfo.timeRemain - 1;
        self.timerButton.setTitle(String(self.gameInfo.timeRemain), for: UIControlState.normal);
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        self.musicController.isHidden = true;
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            return
        }
        if self.paused == true {
            return;
        }
        
        node.removeFromParentNode();
        for i in 0...(self.gameInfo.monsters.count-1) {
            if(self.gameInfo.monsters[i].id == node.name) {
                self.gameInfo.monsters[i].dead = true;
            }
        }
        
        incrementHitCount();
        playSoundEffect();
        
        if(self.mode == Mode.mode1) {
            //case infinity mode
            randomAddNode();
            self.gameInfo.totalMonsterCount += 1;
        }
        
        //for mode2
        if(self.gameInfo.timeLimiting && self.gameInfo.hitCount == self.gameInfo.totalMonsterCount) {
            var score = 0
            if(self.gameInfo.currentLevel == self.gameInfo.maxLevel) {
                self.IsWin = true
                self.timer.invalidate()
                score = GameLevel.levels[0].monsterNum + self.gameInfo.hitCount * 5 + self.gameInfo.timeRemainForLevelOne * 10 + self.gameInfo.timeRemain * 50
                self.performSegue(withIdentifier: "ShowResultView", sender: self)
            } else {
                self.timer.invalidate()
                score = self.gameInfo.hitCount + self.gameInfo.timeRemain * 10
                self.nextLevelView.isHidden = false
            }
            UserDefaults.standard.set(score, forKey: "MODE_2_NEW_SCORE")
        }
    }
    
    func randomAddNode(_ num: Int = 1) {
        for _ in 1...num {
            let m = Monster();
            self.gameInfo.monsters.append(m);
            addModel(m, self.gameInfo.animating);
        }
    }
    
    func playSoundEffect() {
        //TODO:
        MusicManager.sharedInstance.Biu()
    }
    
    func playBgMusic() {
        //TODO:
    }
    
    func incrementHitCount() {
        self.gameInfo.hitCount = self.gameInfo.hitCount + 1;
        if self.mode == Mode.mode2 {
            self.monsterRemainCountLabel.text = String(self.gameInfo.totalMonsterCount - self.gameInfo.hitCount)
        } else {
            self.monsterRemainCountLabel.text = String(self.gameInfo.hitCount)
        }
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowResultView" {
            guard let resultViewControleer = segue.destination as? ResultViewController else {return}
            resultViewControleer.mode = self.mode
            resultViewControleer.IsWin = self.IsWin
        }
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3;
        return float3(translation.x, translation.y, translation.z);
    }
}
