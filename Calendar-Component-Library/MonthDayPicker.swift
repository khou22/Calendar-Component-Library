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

class MonthDayPicker: UIView {
    
    // Options
    private let sensitivity: Int = 8 // X events a day is the peak color
    private let highlightColor = UIColor(colorLiteralRed: 226.0/255.0, green: 111.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    private let colorScheme = UIColor(red: 225.0/255.0, green: 145.0/255.0, blue: 124.0/255.0, alpha: 1.0)
    
    // Delegate to make sure parent conforms
    weak var delegate: DayPickerDelegate?
    
    // Helper to retrieve calendar events
    private let calendarManager: CalendarManager = CalendarManager()
    
    // Current parameters
    private var selectedDate: Date = Date().dateWithoutTime() // Default is today
    
    // Today
    private let currentDate: Date = Date().dateWithoutTime()
    
    // UI Components that will be created on render
    private var leftMonth: UIButton = UIButton()
    private var rightMonth: UIButton = UIButton()
    private var headerLabel: UILabel = UILabel()
    private var tileContainer: UIView = UIView()
    
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
        container.backgroundColor = UIColor.darkGray
        self.tileContainer = container // Set instance variable
        
        self.addSubview(header) // Add header
        self.addSubview(weekdayHeader)
        self.addSubview(container)
    }
    
    public func setDate(date: Date) {
    }
    
    private func createHeader(parent: CGRect) -> UIView {
        // Create the header
        let headerFrame: CGRect = CGRect(x: parent.minX, y: parent.minY, width: parent.width, height: 40)
        let header: UIView = UIView(frame: headerFrame)
        header.backgroundColor = UIColor.white
        
        // Create left/right buttons
        let buttonWidth: CGFloat = 20.0
        let leftFrame = CGRect(x: parent.minX, y: parent.minY, width: buttonWidth, height: headerFrame.height)
        let rightFrame = CGRect(x: parent.maxX - buttonWidth, y: parent.minY, width: buttonWidth, height: headerFrame.height)
        let leftButton: UIButton = UIButton(frame: leftFrame)
        let rightButton: UIButton = UIButton(frame: rightFrame)
        leftButton.backgroundColor = UIColor.blue
        rightButton.backgroundColor = UIColor.blue
        
        leftButton.setTitle("<", for: .normal)
        leftButton.setTitleColor(UIColor.gray, for: .normal)
        rightButton.setTitle(">", for: .normal)
        rightButton.setTitleColor(UIColor.gray, for: .normal)
        
        self.leftMonth = leftButton
        self.rightMonth = rightButton
        
        // Create month/year label
        let headerLabelFrame = CGRect(x: leftFrame.maxX, y: parent.minY, width: parent.width - (2 * buttonWidth), height: headerFrame.height)
        let headerLabel: UILabel = UILabel(frame: headerLabelFrame)
        headerLabel.textAlignment = .center
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
                tile.backgroundColor = UIColor.gray
            }
            
            tile.addSubview(label)
            
            header.addSubview(tile) // Add to parent
        }
        
        return header
    }
    
    private func drawDaySquares() {

    }
    
    private class DayTile {
        
        // Instance variables
        private var view: UIView
        private var label: UILabel
        private var id: Int
        private var backgroundColor: UIColor
        private var highlightColor: UIColor
        private var selected: Bool = false // Default is false
        private var selectedMarker: UIView
        
        init(id: Int, frame: CGRect, label: String, highlight: UIColor, background: UIColor) {
            // Set instance variables
            self.id = id
            self.label = UILabel(frame: frame)
            self.backgroundColor = background
            self.highlightColor = highlight
            self.view = UIView(frame: frame) // Create tile from frame
            self.label = DayTile.createLabel(frame: frame, label: label) // Create UI label
            self.selectedMarker = DayTile.createHighlightMarker(parent: frame, highlightColor: highlight)
        }
        
        private func drawSquare() {
            // Set meta data
            self.view.tag = self.id
        }
        
        public func addToView(parent: UIView) {
            parent.addSubview(self.view) // Add the tile to the subview
        }
        
        private static func createLabel(frame: CGRect, label: String) -> UILabel {
            let dateLabel: UILabel = UILabel(frame: frame) // Create label
            dateLabel.text = label // Set text
            dateLabel.textAlignment = .center // Center aligned
            dateLabel.adjustsFontSizeToFitWidth = true
            dateLabel.font.withSize(10.0)
            dateLabel.textColor = UIColor.black
            
            return dateLabel
        }
        
        private static func createHighlightMarker(parent: CGRect, highlightColor: UIColor) -> UIView {
            let scale: CGFloat = 0.825 // Percent scaled down
            let minLength: CGFloat = min(parent.width, parent.height)
            
            let padding: CGFloat = minLength * ((1 - scale) / 2) // Calculate the padding
            let markerFrame: CGRect = CGRect(x: parent.minX + padding, y: parent.minY + padding, width: parent.width * scale, height: parent.height * scale)
            let marker: UIView = UIView(frame: markerFrame)
            marker.backgroundColor = highlightColor
            
            // Make into a circle
            marker.layer.cornerRadius = minLength / 2
            marker.layer.masksToBounds = true
            marker.layer.isHidden = true // Hide all initially
            
            return marker
        }
        
        public func select() {
            self.selectedMarker.layer.isHidden = false // Make highlight marker visible
            self.label.textColor = UIColor.white // Make text white
            self.label.font.withSize(14.0)
            self.animateHighlight() // Animate the highlight interaction
        }
        
        public func deselect() {
            self.selectedMarker.layer.isHidden = true // Make highlight marker invisible
            self.label.textColor = UIColor.black // Make text black again
            self.label.font.withSize(10.0)
        }
        
        private func animateHighlight() {
            self.selectedMarker.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Animate large to normal
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                self.selectedMarker.transform = .identity // Make normal size
            }, completion: nil)
        }
    }
}
