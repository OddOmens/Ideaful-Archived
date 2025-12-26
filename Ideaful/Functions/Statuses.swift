import SwiftUI

struct GlobalConstants {
    static let statusColors: [String: Color] = [
        "Unassigned": Color(hex: "#A5B1C2"),
        "New Idea": Color(hex: "#E456F0"),
        "Ideation": Color(hex: "#A55EEA"),
        "Not Started": Color(hex: "#FC5C65"),
        "Started": Color(hex: "#26DE81"),
        "Researching": Color(hex: "#2BCBBA"),
        "Planning": Color(hex: "#4B7BEC"),
        "Developing": Color(hex: "#A55EEA"),
        "Prototyping": Color(hex: "#E456F0"),
        "Testing": Color(hex: "#FD9644"),
        "Troubleshooting": Color(hex: "#FF6B6B"),
        "Reviewing": Color(hex: "#FD9644"),
        "Deferred": Color(hex: "#FD9644"),
        "Blocked": Color(hex: "#FC5C65"),
        "Maintenance": Color(hex: "#26DE81"),
        "Quality Control": Color(hex: "#FD9644"),
        "Awaiting Feedback": Color(hex: "#2BCBBA"),
        "Awaiting Resources": Color(hex: "#2BCBBA"),
        "Pre-Production": Color(hex: "#4B7BEC"),
        "Production": Color(hex: "#A55EEA"),
        "Post-Production": Color(hex: "#E456F0"),
        "Documentation": Color(hex: "#54A0FF"),
        "On Hold": Color(hex: "#FD9644"),
        "Marketing": Color(hex: "#4B7BEC"),
        "Released": Color(hex: "#26DE81"),
        "Sunsetting": Color(hex: "#FD9644"),
        "Completed": Color(hex: "#26DE81"),
        "Cancelled": Color(hex: "#FC5C65"),
        "Abandoned": Color(hex: "#FC5C65"),
        "Archived": Color(hex: "#A5B1C2"),
        "Funded": Color(hex: "#20BF6B"),
        "Seeking Funding": Color(hex: "#0FB9B1"),
        "Pitching": Color(hex: "#45AAF2"),
        "Validated": Color(hex: "#26DE81"),
        "Under Review": Color(hex: "#FD9644"),
    ]
    
    static let orderedStatuses: [String] = [
        "Unassigned", "New Idea", "Ideation", "Not Started", "Started",
        "Researching", "Planning", "Developing", "Prototyping", "Testing", "Troubleshooting",
        "Reviewing", "Pitching", "Seeking Funding", "Funded", "Validated", "Under Review", 
        "Deferred", "Blocked", "Maintenance", "Quality Control",
        "Awaiting Feedback", "Awaiting Resources", "Pre-Production", "Production",
        "Post-Production", "On Hold", "Documentation", "Marketing", "Sunsetting", "Released", "Completed",
        "Cancelled", "Abandoned", "Archived"
    ]
    
    static func localizedStatus(_ status: String) -> String {
        return NSLocalizedString(status, comment: "")
    }
    
    // Unique colors from status system for tag picker
    static let tagColors: [String] = [
        "#A5B1C2", "#E456F0", "#A55EEA", "#FC5C65", "#26DE81", 
        "#2BCBBA", "#4B7BEC", "#FD9644", "#FF6B6B", "#54A0FF", 
        "#20BF6B", "#0FB9B1", "#45AAF2"
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
