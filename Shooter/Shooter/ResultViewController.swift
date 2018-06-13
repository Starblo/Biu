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
    
    @IBAction func GoBackAction(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
