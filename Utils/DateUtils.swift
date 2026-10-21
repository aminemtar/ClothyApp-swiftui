//
//  DateUtils.swift
//  ClothyApp
//

import Foundation

enum DateUtils {
    /// Parses ISO-8601 dates returned by the API.
    /// Returns nil for invalid input instead of silently substituting "now".
    static func formatFromString(string: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: string) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: string) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: string) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: string)
    }

    static func formatFromDate(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    static func formatFromDateForDisplayHoursMin(date: Date) -> String {
        displayFormatter("HH:mm").string(from: date)
    }

    static func formatFromDateForDisplayYearMonthDay(date: Date) -> String {
        displayFormatter("dd-MM-yyyy").string(from: date)
    }

    static func formatFromDateForDisplayAll(date: Date) -> String {
        displayFormatter("dd-MM-yyyy - HH:mm").string(from: date)
    }

    private static func displayFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .none
        formatter.dateFormat = format
        return formatter
    }

    static func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        (seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }
}

extension Date {
    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        calendar.component(component, from: self) - calendar.component(component, from: date)
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }

    func years(from date: Date) -> Int {
        Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    func months(from date: Date) -> Int {
        Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    func weeks(from date: Date) -> Int {
        Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }

    func days(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    func hours(from date: Date) -> Int {
        Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    func minutes(from date: Date) -> Int {
        Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func seconds(from date: Date) -> Int {
        Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    func offset(from date: Date) -> String {
        if years(from: date) > 0 { return "\(years(from: date))y" }
        if months(from: date) > 0 { return "\(months(from: date))M" }
        if weeks(from: date) > 0 { return "\(weeks(from: date))w" }
        if days(from: date) > 0 { return "\(days(from: date))d" }
        if hours(from: date) > 0 { return "\(hours(from: date))h" }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
