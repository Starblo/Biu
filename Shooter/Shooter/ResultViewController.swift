//
//  ResultViewController.swift
//  Shooter
//
//  Created by hdc_iMac on 2018/6/13.
//  Copyright © 2018年 Starblo Hong. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    @IBOutlet weak var WinOrLoseLabel: UILabel!
    @IBOutlet weak var SaySomethingLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    
    @IBOutlet weak var BackButton: UIButton!
    
    var IsWin : Bool = false
    var mode : Mode = Mode.mode1
    
    @IBAction func GoBackAction(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        BackButton.animate(from: .bottom, and: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        self.BackButton.layer.cornerRadius = self.BackButton.bounds.height/2
        if self.mode == Mode.mode1 {
            let score = UserDefaults.standard.integer(forKey: "MODE_1_NEW_SCORE")
            let highest_score = UserDefaults.standard.integer(forKey: "HighestScore_Mode1")
            if score > highest_score {
                WinOrLoseLabel.text = "Excellent"
                SaySomethingLabel.text = "New Highest Score"
                ScoreLabel.text = String(score)
                UserDefaults.standard.set(score, forKey: "HighestScore_Mode1")
                MusicManager.sharedInstance.bigSuccess()
            } else {
                WinOrLoseLabel.text = "Good"
                SaySomethingLabel.text = "Try It Again"
                ScoreLabel.text = String(score)
                MusicManager.sharedInstance.Success()
            }
        } else {
            let score = UserDefaults.standard.integer(forKey: "MODE_2_NEW_SCORE")
            let highest_score = UserDefaults.standard.integer(forKey: "HighestScore_Mode2")
            if score > highest_score && IsWin == true {
                WinOrLoseLabel.text = "Excellent"
                SaySomethingLabel.text = "New Highest Score"
                ScoreLabel.text = String(score)
                UserDefaults.standard.set(score, forKey: "HighestScore_Mode2")
                MusicManager.sharedInstance.bigSuccess()
            } else if IsWin == true {
                WinOrLoseLabel.text = "You Win"
                SaySomethingLabel.text = "Great Game"
                ScoreLabel.text = String(score)
                MusicManager.sharedInstance.Success()
            } else {
                WinOrLoseLabel.text = "What a Pity"
                SaySomethingLabel.text = "Try It Again"
                ScoreLabel.text = String(score)
                if score > highest_score {
                    UserDefaults.standard.set(score, forKey: "HighestScore_Mode2")
                }
                MusicManager.sharedInstance.Fail()
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
