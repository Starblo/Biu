//
//  ModeViewController.swift
//  Shooter
//
//  Created by Starblo Hong on 12/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import UIKit

class ModeViewController: UIViewController {
    @IBOutlet weak var VisualView: UIVisualEffectView!
    @IBOutlet weak var ModeLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var HighestScoreLabel: UILabel!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var ContinueButton: UIButton!
    
    var mode : Mode = .mode1
    var loadFromLocalFile : Bool = false
    var HighestScore : Int = 0
    
    @IBAction func PlayAction(_ sender: UIButton) {
    }
    @IBAction func ContinueAction(_ sender: UIButton) {
    }
    @IBAction func TapAction(_ sender: UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        self.PlayButton.layer.cornerRadius = self.PlayButton.bounds.height/2
        self.ContinueButton.layer.cornerRadius = self.ContinueButton.bounds.height/2
        if self.mode == Mode.mode1 {
            self.ModeLabel.text = "Mode1"
            self.loadFromLocalFile = UserDefaults.standard.bool(forKey: "LoadFromLocalFile_Mode1")
            self.HighestScore = UserDefaults.standard.integer(forKey: "HighestScore_Mode1")
            ImageView.image = #imageLiteral(resourceName: "Rules_Mode1")
        }
        if self.mode == Mode.mode2 {
            self.ModeLabel.text = "Mode2"
            self.HighestScore = UserDefaults.standard.integer(forKey: "HighestScore_Mode2")
            self.loadFromLocalFile = UserDefaults.standard.bool(forKey: "LoadFromLocalFile_Mode2")
            ImageView.image = #imageLiteral(resourceName: "Rules_Mode2")
        }
        
        if self.loadFromLocalFile == true {
            self.ContinueButton.isHidden = false
        } else {
            self.ContinueButton.isHidden = true
        }
        
        self.HighestScoreLabel.text = String(self.HighestScore)

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Play" {
            guard let gameViewController = segue.destination as? GameViewController else {return}
            gameViewController.mode = self.mode
            if mode == Mode.mode1 {
                UserDefaults.standard.set(false, forKey: "LoadFromLocalFile_Mode1")
            } else {
                UserDefaults.standard.set(false, forKey: "LoadFromLocalFile_Mode2")
            }
        }
        else if segue.identifier == "Continue" {
            guard let gameViewControleer = segue.destination as? GameViewController else {return}
            gameViewControleer.mode = self.mode
        }
    }
    

}
