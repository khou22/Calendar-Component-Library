//
//  MonthDayPicker.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import UIKit
import EventKit

@objc protocol MonthDayPickerDelegate: class {
    @objc optional func dateChange(date: Date)
}

class MonthDayPicker: UIView, DayTileDelegate {
    
    // Options
    private let sensitivity: CGFloat = 8.0 // X events a day is the peak color
    private let highlightColor = UIColor(colorLiteralRed: 226.0/255.0, green: 111.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    private let colorScheme = UIColor(red: 225.0/255.0, green: 145.0/255.0, blue: 124.0/255.0, alpha: 1.0)
    
    // Colors
    private let lightGrey = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0)
    private let grey = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    private let darkGrey = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    
    // Delegate to make sure parent conforms
    weak var delegate: MonthDayPickerDelegate?
    
    // Helper to retrieve calendar events
    private let calendarManager: CalendarManager = CalendarManager()
    
    // Current parameters
    private var selectedIndex: Int = 0
    private var selectedDate: Date = Date().dateWithoutTime() // Default is today
    private var monthAchor: Date = Date().dateWithoutTime() // Anchors the month/year
    
    // Today
    private let currentDate: Date = Date().dateWithoutTime()
    
    // UI Components that will be created on render
    private var leftMonth: UIButton = UIButton()
    private var rightMonth: UIButton = UIButton()
    private var headerLabel: UILabel = UILabel()
    private var tileContainer: UIView = UIView()
    private var tiles: [DayTile] = []
    
    override func draw(_ rect: CGRect) {
        calendarManager.requestAuthorization(completion: { (success) in
            print("Success: \(success)")
        })
        self.backgroundColor = UIColor.white
        
        // Headers
        let header: UIView = createHeader(parent: rect);
        let weekdayHeader: UIView = createWeekdayHeader(frame: CGRect(x: rect.minX, y: header.frame.maxY, width: rect.width, height: 30))
        
        // Construct the container that will house all the tiles
        let headerHeights: CGFloat = header.frame.height + weekdayHeader.frame.height
        let containerFrame: CGRect = CGRect(x: rect.minX, y: rect.minY + headerHeights, width: rect.width, height: rect.height - headerHeights)
        let container: UIView = UIView(frame: containerFrame)
        container.backgroundColor = UIColor.white
        self.tileContainer = container // Set instance variable
        
        self.addSubview(header) // Add header
        self.addSubview(weekdayHeader)
        self.addSubview(container)
        
        // Add the tiles to the container view
        drawDaySquares()
    }
    
    private func createHeader(parent: CGRect) -> UIView {
        // Create the header
        let headerFrame: CGRect = CGRect(x: parent.minX, y: parent.minY, width: parent.width, height: 50)
        let header: UIView = UIView(frame: headerFrame)
        header.backgroundColor = UIColor.white
        
        // Create left/right buttons
        let buttonWidth: CGFloat = 40.0
        let leftFrame = CGRect(x: parent.minX, y: parent.minY, width: buttonWidth, height: headerFrame.height)
        let rightFrame = CGRect(x: parent.maxX - buttonWidth, y: parent.minY, width: buttonWidth, height: headerFrame.height)
        let leftButton: UIButton = UIButton(frame: leftFrame)
        let rightButton: UIButton = UIButton(frame: rightFrame)
        
        leftButton.setTitle("<", for: .normal)
        leftButton.setTitleColor(self.darkGrey, for: .normal)
        leftButton.addTarget(self, action: #selector(self.previousMonth(sender:)), for: .touchUpInside)
        rightButton.setTitle(">", for: .normal)
        rightButton.setTitleColor(self.darkGrey, for: .normal)
        rightButton.addTarget(self, action: #selector(self.nextMonth(sender:)), for: .touchUpInside)
        
        self.leftMonth = leftButton
        self.rightMonth = rightButton
        
        // Create month/year label
        let headerLabelFrame = CGRect(x: leftFrame.maxX, y: parent.minY, width: parent.width - (2 * buttonWidth), height: headerFrame.height)
        let headerLabel: UILabel = UILabel(frame: headerLabelFrame)
        headerLabel.textAlignment = .center
        headerLabel.textColor = self.darkGrey
        headerLabel.font.withSize(22.0) // Larger font size
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM y"
        headerLabel.text = formatter.string(from: self.currentDate)
        
        self.headerLabel = headerLabel
        
        // Add to parent
        header.addSubview(leftButton)
        header.addSubview(rightButton)
        header.addSubview(headerLabel)
        
        return header
    }
    
    private func createWeekdayHeader(frame: CGRect) -> UIView {
        let header = UIView(frame: frame)
        header.backgroundColor = UIColor.white
        
        let labels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        let baseWidth: CGFloat = frame.width / 7.0
        for weekday in 0..<7 { // All 7 days of the week
            let dayFrame = CGRect(x: CGFloat(weekday) * baseWidth, y: 0, width: baseWidth, height: frame.height)
            let tile: UIView = UIView(frame: dayFrame)
            
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: dayFrame.width, height: dayFrame.height)) // Cover entire tile
            label.textAlignment = .center
            label.text = labels[weekday]
            
            if (weekday % 2 == 1) { // Odd number
                tile.backgroundColor = self.lightGrey
            } else {
                tile.backgroundColor = self.grey
            }
            
            tile.addSubview(label)
            
            header.addSubview(tile) // Add to parent
        }
        
        return header
    }
    
    private func drawDaySquares() {
        let firstDayOfMonth: Date = self.monthAchor.firstDayInMonth()
        let startingWeekday: Int = firstDayOfMonth.getWeekday()
        let lengthOfMonth: Int = firstDayOfMonth.lengthOfMonth()
        let numberOfRows: CGFloat = CGFloat(ceil(Double(startingWeekday + lengthOfMonth) / 7.0)) // Number of rows needed
        
        // Base sizing
        let baseWidth = self.tileContainer.frame.width / 7.0
        var baseHeight = self.tileContainer.frame.height / numberOfRows
        
        baseHeight = baseHeight > baseWidth ? baseWidth : baseHeight // Should never be taller than it is wide
        
        // Store instance of each day in global array
        self.tiles = [] // Reset
        
        // For each day of the month
        for i in 0..<lengthOfMonth {
            let dateForTile: Date = firstDayOfMonth.addingTimeInterval(Double(i) * 24.0 * 60.0 * 60.0) // Add i number of days
            let gridIndex = startingWeekday + i // The position in "grid"
            
            // Get the x and y coordinates
            let xIndex = gridIndex % 7
            let yIndex = floor(Double(gridIndex) / 7.0)
            
            // Calculate background color
            var opacity: CGFloat = CGFloat(calendarManager.getEvents(day: dateForTile).count) / self.sensitivity
            if (opacity >= 1.0) { opacity = 1.0 } // Max full opacity
            let backgroundColor: UIColor = self.colorScheme.withAlphaComponent(opacity)
            
            let tileFrame: CGRect = CGRect(x: CGFloat(xIndex) * baseWidth, y: CGFloat(yIndex) * baseHeight, width: baseWidth, height: baseHeight)
            let tile: DayTile = DayTile(id: i, frame: tileFrame, label: String(i + 1), highlight: self.highlightColor, background: backgroundColor)
            
            tile.addToView(parent: self.tileContainer) // Add to the tile container
            tile.delegate = self
            self.tiles.append(tile)
        }
    }
    
    // MARK - User Interaction Actions
    
    // Move to the next month
    @objc private func nextMonth(sender: UIButton!) {
        let daysAhead = Double(self.monthAchor.lengthOfMonth()) + 15.0 // Go to middle of next month
        let midNextMonth: Date = self.monthAchor.addingTimeInterval(daysAhead * 24.0 * 60.0 * 60.0)
        self.monthAchor = midNextMonth.firstDayInMonth() // Advance to first day of next month
        
        repopulate()
    }
    
    // Move to the previous month
    @objc private func previousMonth(sender: UIButton!) {
        let midPreviousMonth: Date = self.monthAchor.addingTimeInterval(-15 * 24.0 * 60.0 * 60.0)
        self.monthAchor = midPreviousMonth.firstDayInMonth() // Advance to first day of previous month
        
        repopulate()
    }
    
    // Redraw neccessary assets
    private func repopulate() {
        
        // Update header
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM y"
        self.headerLabel.text = formatter.string(from: self.monthAchor)
        
        // Remove all views from tile container
        for view in self.tileContainer.subviews {
            view.removeFromSuperview()
        }
    
        drawDaySquares() // Redraw the tiles
    }
    
    // When a date is selected
    func selected(id: Int) {
        self.tiles[self.selectedIndex].deselect()
        self.tiles[id].select()
        self.selectedIndex = id // Update which is selected
    }
}
