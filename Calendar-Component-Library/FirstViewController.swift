//
//  FirstViewController.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, DayPickerDelegate {

    @IBOutlet weak var DayPicker: DayPicker!
    @IBOutlet weak var selectedDateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        DayPicker.delegate = self // Delegate to self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dateChange(date: Date) {
        print("Date changed to \(date)")
        selectedDateLabel.text = String(describing: date)
    }

    @IBAction func updateDate(_ sender: Any) {
        let newDate: Date = Date().dateWithoutTime().addingTimeInterval(10 * 24.0 * 60.0 * 60.0)
        DayPicker.setDate(date: newDate)
    }
}

