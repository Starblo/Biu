//
//  HomeViewController.swift
//  Shooter
//
//  Created by Starblo Hong on 12/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mode1Button: UIButton!
    @IBOutlet weak var mode2Button: UIButton!
    
    var sendMode: Mode = Mode.mode1
    
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
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mode1" {
            guard let modeViewController = segue.destination as? ModeViewController else {return}
            modeViewController.mode = Mode.mode1
        }
        else if segue.identifier == "mode2" {
            guard let modeViewController = segue.destination as? ModeViewController else {return}
            modeViewController.mode = Mode.mode2
        }
        else{
            return
        }
    }
 

}
