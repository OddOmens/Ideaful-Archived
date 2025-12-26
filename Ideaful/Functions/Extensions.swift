import SwiftUI
import Foundation

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


func incrementAppLaunchCount() {
    let defaults = UserDefaults.standard
    let launchCount = defaults.integer(forKey: "launchCount") + 1
    defaults.set(launchCount, forKey: "launchCount")
}


extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}

