import Foundation
import CoreData
import SwiftUI

@objc(Tag)
public class Tag: NSManagedObject {
    
}

extension Tag {
    var displayName: String {
        return name ?? "New Tag"
    }
    
    var colorValue: Color {
        get {
            switch self.color ?? "colorPrimary" {
            case "colorBlue": return Color.colorBlue
            case "colorGreen": return Color.colorGreen
            case "colorRed": return Color.colorRed
            case "colorOrange": return Color.colorOrange
            case "colorPurple": return Color.colorPurple
            case "colorYellow": return Color.colorYellow
            case "colorTeal": return Color.colorTeal
            case "colorMagenta": return Color.colorMagenta
            case "colorGrey": return Color.colorGrey
            default: return Color.colorPrimary
            }
        }
        set {
            switch newValue {
            case Color.colorBlue: self.color = "colorBlue"
            case Color.colorGreen: self.color = "colorGreen"
            case Color.colorRed: self.color = "colorRed"
            case Color.colorOrange: self.color = "colorOrange"
            case Color.colorPurple: self.color = "colorPurple"
            case Color.colorYellow: self.color = "colorYellow"
            case Color.colorTeal: self.color = "colorTeal"
            case Color.colorMagenta: self.color = "colorMagenta"
            case Color.colorGrey: self.color = "colorGrey"
            default: self.color = "colorPrimary"
            }
        }
    }
    
    var sortedIdeas: [Idea] {
        let ideasSet = ideas as? Set<Idea> ?? []
        return ideasSet.sorted { idea1, idea2 in
            (idea1.updateDate ?? Date.distantPast) > (idea2.updateDate ?? Date.distantPast)
        }
    }
}