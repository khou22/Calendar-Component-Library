//
//  DateHelper.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import Foundation

extension Date {
    
    // Get date without time
    func dateWithoutTime() -> Date {
        let dateFormatter = DateFormatter() // Initialize new Date Formatter

        dateFormatter.dateStyle = .medium // Doesn't include time component
        let dateToPrint: NSString = dateFormatter.string(from: self) as NSString // Format into medium style string
        let dateNoTime = dateFormatter.date(from: dateToPrint as String) // Get a date from midnight that day

        return dateNoTime! // Return result
    }
    
    func getWeekday() -> Int {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let components: DateComponents = calendar!.components(.weekday, from: self) // Get day of the week
        return components.weekday! - 1 // Return weekday
    }
    
    func daysAhead(_ days: Int) -> Date {
        let timeAgo: TimeInterval = TimeInterval(days * 24 * 60 * 60) // 24 hours, 60 minutes, 60 seconds
        let newDate: Date = Date(timeInterval: timeAgo, since: self)
        return newDate // Return the date
    }
    
    func getDay() -> Int {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let components: DateComponents = calendar!.components(.day, from: self)
        return components.day!
    }
    
    func getMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    func getYear() -> Int {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let components: DateComponents = calendar!.components(.day, from: self)
        return components.year!
    }
    
    func firstDayInMonth() -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let components: DateComponents = calendar!.components([.year, .month], from: self)
        return calendar!.date(from: components)!
    }
    
    func lengthOfMonth() -> Int {
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let daysInMonth = calendar.range(of: .day, in: .month, for: self)
        return daysInMonth.length
    }
}
