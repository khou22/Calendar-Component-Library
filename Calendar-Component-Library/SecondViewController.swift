//
//  SecondViewController.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var monthDayPicker: MonthDayPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setDateAheadFourty(_ sender: Any) {
        let newDate = Date().dateWithoutTime().addingTimeInterval(40.0 * 24.0 * 60.0 * 60.0)
        monthDayPicker.setDate(date: newDate)
    }
}

