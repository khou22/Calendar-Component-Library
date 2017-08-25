//
//  CalendarManager.swift
//  Calendar-Component-Library
//
//  Created by Kevin Hou on 8/24/17.
//  Copyright © 2017 Kevin Hou. All rights reserved.
//

import Foundation
import EventKit

class CalendarManager {

    private let eventStore: EKEventStore = EKEventStore()
    
    func requestAuthorization(completion: @escaping (_ success: Bool) -> Void) {
        if (EKEventStore.authorizationStatus(for: .event) == .notDetermined) {
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (error != nil) {
                    print("Error \(String(describing: error))")
                    completion(false)
                } else {
                    print("Granted access \(granted)")
                    completion(true)
                }
            })
        }
    }
    
    func getEvents(day: Date) -> [EKEvent] {
        let start: Date = day.dateWithoutTime() // Current day
        let end: Date = start.addingTimeInterval(24.0 * 60.0 * 60.0) // Exactly one day after
        let calendars: [EKCalendar] = eventStore.calendars(for: .event) // For all calendars
        let predicate: NSPredicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events: [EKEvent] = self.eventStore.events(matching: predicate) // Return events
//        print("Retrieved \(events.count) events")
        return events
    }
}
