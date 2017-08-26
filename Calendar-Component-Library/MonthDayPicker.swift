//
//  MonthDayPicker.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import UIKit
import EventKit

@objc protocol DayPickerDelegate: class {
    @objc optional func dateChange(date: Date)
}

class DayPicker: UIView {
    
    // Delegate to make sure parent conforms
    weak var delegate: DayPickerDelegate?
    
    // Helper to retrieve calendar events
    private let calendarManager: CalendarManager = CalendarManager()

    private var weeksToShow: Int = 4 // Default view 4 weeks
    private let currentDate: Date = Date().dateWithoutTime()
    private let sensitivity: Int = 8 // X events a day is the peak color
    
    private let highlightColor = UIColor(colorLiteralRed: 226.0/255.0, green: 111.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    private let colorScheme = UIColor(red: 225.0/255.0, green: 145.0/255.0, blue: 124.0/255.0, alpha: 1.0)
    
    // Variables that will change on render
    private var startingDate: Date = Date().dateWithoutTime()
    public var selectedIndex: Int = Date().getWeekday()
    private var inactiveDays: Int = Date().getWeekday() // Number of inactive tiles that happen before the current date
    private var events: [[EKEvent]] = Array(repeating: [], count: (4 * 7) + Date().getWeekday()) // Array of events for each day
    private var tileDates: [Date] = Array(repeating: Date().dateWithoutTime(), count: (4 * 7) + Date().getWeekday()) // Map ID to date
    private var tiles: [UIView] = Array(repeating: UIView(), count: (4 * 7) + Date().getWeekday()) // Map ID to UIView
    private var tileCircles: [UIView] = Array(repeating: UIView(), count: (4 * 7) + Date().getWeekday()) // Map ID to UIView
    private var tileText: [UILabel] = Array(repeating: UILabel(), count: (4 * 7) + Date().getWeekday()) // Map ID to UIView
    
    override func draw(_ rect: CGRect) {
        calendarManager.requestAuthorization(completion: { (success) in
            print("Success: \(success)")
        })
        self.backgroundColor = UIColor.white
        initializeData() // Initialize instance variables
        drawDaySquares() // Initialize UI
        updateSelectedDay(newID: selectedIndex) // Set initial
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
            if (tileDates[i].compare(currentDate) != .orderedAscending) { // Current date is earlier than today's date
                // Sizing and positioning
                let x = CGFloat(i % 7) * sideLength
                let y = CGFloat(floor(Double(i / 7))) * sideLength
                let tileRect: CGRect = CGRect(x: x, y: y, width: sideLength, height: sideLength)
                let tile: UIView = UIView(frame: tileRect)

                // Styling
                var opacity: CGFloat = CGFloat(Double(events[i].count) / Double(sensitivity))
                if (opacity >= 1.0) { opacity = 1.0 } // Max full opacity
                tile.backgroundColor = colorScheme.withAlphaComponent(opacity)
                
                // Meta Data
                tile.tag = i // Attach ID as tag
                
                // Tap functionality
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapTile(sender:)))
                tile.addGestureRecognizer(tap)
                
                // Add date label
                let dateLabel: UILabel = UILabel(frame: tileRect)
                dateLabel.text = String(tileDates[i].getDay()) // Set text
                dateLabel.textAlignment = .center // Center aligned
                dateLabel.adjustsFontSizeToFitWidth = true
                dateLabel.font.withSize(10.0)
                
                // Create seperate selected circle indicator
                let circle: UIView = highlightCircle(id: i, x: x, y: y, containerSize: sideLength)
                
                // Add subview
                tiles[i] = tile // Store
                tileCircles[i] = circle
                tileText[i] = dateLabel
                self.addSubview(tile)
                self.addSubview(circle)
                self.addSubview(dateLabel)
            }
        }
    }
    
    private func highlightCircle(id: Int, x: CGFloat, y: CGFloat, containerSize: CGFloat) -> UIView {
        let scale: CGFloat = 0.825 // Percent scaled down
        let padding: CGFloat = containerSize * ((1 - scale) / 2) // Calculate the padding
        let circleSize: CGFloat = containerSize * scale
        let circleFrame: CGRect = CGRect(x: x + padding, y: y + padding, width: circleSize, height: circleSize)
        let circle: UIView = UIView(frame: circleFrame)
        circle.backgroundColor = highlightColor
        
        // Make into a circle
        circle.layer.cornerRadius = circleSize / 2
        circle.layer.masksToBounds = true
        circle.layer.isHidden = true // Hide all initially
        
        return circle
    }
    
    func tapTile(sender: UITapGestureRecognizer) {
        updateSelectedDay(newID: sender.view!.tag)
    }
    
    func updateSelectedDay(newID: Int) {
        let datePicked: Date = tileDates[newID]
        
        tileCircles[selectedIndex].layer.isHidden = true // Reset previous
        tileText[selectedIndex].textColor = UIColor.black // Reset color
        tileText[selectedIndex].font.withSize(10.0) // Reset font size

        tileCircles[newID].layer.isHidden = false // Make circle visible
        tileText[newID].textColor = UIColor.white // Change font to white
        tileText[newID].font.withSize(14.0) // Increase font size
        animateHighlight(id: newID)
        
        selectedIndex = newID // Update record
        delegate?.dateChange?(date: datePicked) // Send the date to the delegate
    }
    
    private func animateHighlight(id: Int) {
        self.tileCircles[id].transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
            self.tileCircles[id].transform = .identity // Reset
        }, completion: nil)
    }
}
