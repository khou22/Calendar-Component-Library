//
//  MonthDayPicker.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import UIKit
import EventKit

class MonthDayPicker: UIView {
    
    // Helper to retrieve calendar events
    private let calendarManager: CalendarManager = CalendarManager()

    private var weeksToShow: Int = 4 // Default view 4 weeks
    private let currentDate: Date = Date().dateWithoutTime()
    
    private let colorScheme = UIColor(red: 226.0/255.0, green: 111.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    
    // Variables that will change on render
    private var startingDate: Date = Date().dateWithoutTime()
    private var events: [[EKEvent]] = Array(repeating: [], count: 4 * 7) // Array of events for each day
    private var tileDates: [Date] = Array(repeating: Date().dateWithoutTime(), count: 4 * 7) // Map ID to date
    private var tiles: [UIView] = Array(repeating: UIView(), count: 4 * 7) // Map ID to UIView
    
    override func draw(_ rect: CGRect) {
        calendarManager.requestAuthorization(completion: { (success) in
            print("Success: \(success)")
        })
        self.backgroundColor = UIColor.white
        initializeData() // Initialize instance variables
        drawDaySquares() // Initialize UI
    }
    
    func initializeData() {
        let weekday: Int = currentDate.getWeekday()
        let startingDate = currentDate.daysAhead(-weekday) // In the past
        self.startingDate = startingDate // Store as instance variables
        
        // Calculate the dates visible
        for i in 0..<self.tileDates.count {
            let tileDate: Date = self.startingDate.daysAhead(i)
            tileDates[i] = tileDate // Store in master array
            events[i] = calendarManager.getEvents(day: tileDate) // Get events for the day
        }
    }
    
    func drawDaySquares() {
        // Store dimensions
        let sideLength: CGFloat = self.bounds.width / 7
        
        for i in 0..<self.tileDates.count {
            // Sizing and positioning
            let x = CGFloat(i % 7) * sideLength
            let y = CGFloat(floor(Double(i / 7))) * sideLength
//            print("\(i) at (\(x), \(y))")
            let tileRect: CGRect = CGRect(x: x, y: y, width: sideLength, height: sideLength)
            let tile: UIView = UIView(frame: tileRect)
            
            // Styling
            var opacity: CGFloat = CGFloat(Double(events[i].count) / 6.0)
            if (opacity >= 1.0) { opacity = 1.0 } // Max full opacity
//            print("Opacity \(opacity)")
            tile.backgroundColor = colorScheme.withAlphaComponent(opacity)
//            tile.layer.borderWidth = 1
//            tile.layer.borderColor = UIColor.gray.cgColor
            
            // Meta Data
            tile.tag = i // Attach ID as tag
            
            // Tap functionality
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapTile(sender:)))
            tile.addGestureRecognizer(tap)
            
            // Add date label
            let frame: CGRect = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
            let dateLabel: UILabel = UILabel(frame: frame)
            dateLabel.text = String(tileDates[i].getDay()) // Set text
            dateLabel.textAlignment = .center // Center aligned
            tile.addSubview(dateLabel)
            
            // Add subview
            tiles[i] = tile // Store
            self.addSubview(tile)
        }
    }
    
    func tapTile(sender: UITapGestureRecognizer) {
        print("Tapped: \(sender.view?.tag)")
    }
}
