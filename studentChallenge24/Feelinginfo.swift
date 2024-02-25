

import SwiftData

@Model
class Feelinginfo {
    @Attribute(.unique) var date: String
    var feeling: String
    var reason: String
    init(date: String, feeling: String, reason: String) {
        self.date = date
        self.feeling = feeling
        self.reason = reason
    }
}
