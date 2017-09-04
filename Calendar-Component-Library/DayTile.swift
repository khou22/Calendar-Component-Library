//
//  DayTile.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 9/3/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import Foundation
import UIKit

class DayTile {
    
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
        
        drawSquare()
    }
    
    private func drawSquare() {
        // Set meta data
        self.view.tag = self.id
        
        // Style tile
        self.view.backgroundColor = self.backgroundColor
        
        // Add content to view
        self.view.addSubview(self.label)
        self.view.addSubview(self.selectedMarker)
    }
    
    public func addToView(parent: UIView) {
        parent.addSubview(self.view) // Add the tile to the subview
    }
    
    private static func createLabel(frame: CGRect, label: String) -> UILabel {
        let dateLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)) // Create label
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
        let markerFrame: CGRect = CGRect(x: padding, y: padding, width: parent.width * scale, height: parent.height * scale)
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
