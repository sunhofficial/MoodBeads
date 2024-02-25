
import Foundation
extension Date {
    public func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        return formatter.string(from: self)
    }
    public func nowtimeFormatted() -> String {
        let today = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateformatter.string(from: today)
        return todayDateString
    }
}
