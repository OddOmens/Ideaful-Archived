import SwiftUI
import CoreData
import StoreKit
import UserNotifications
import Combine

enum CurrentView {
    case main
    case achievements
}

class NavigationState: ObservableObject {
    @Published var currentView: CurrentView = .main
}

@main
struct Ideaful: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("launchCount") private var launchCount = 0
    @AppStorage("reviewPromptLastShown") private var reviewPromptLastShown = 0
    @AppStorage("userChoseToReviewLater") private var userChoseToReviewLater = false
    @AppStorage("userDeclinedToReview") private var userDeclinedToReview = false
    
    let persistenceController = PersistenceController.shared

    @StateObject var languageManager = LanguageManager.shared
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var statusManager: StatusManager
    @StateObject private var userSettings = UserSettings()
    @StateObject private var navigationState = NavigationState()
    @StateObject private var iconManager: IconManager

    init() {
        let context = persistenceController.container.viewContext
        let settings = UserSettings()
        let manager = IconManager(viewContext: context, userSettings: settings)
        _userSettings = StateObject(wrappedValue: settings)
        _iconManager = StateObject(wrappedValue: manager)
        _statusManager = StateObject(wrappedValue: StatusManager(viewContext: context))
        updateInvalidStatuses(context: context)
        incrementLaunchCount()
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea(.keyboard)
                .environmentObject(languageManager)
                .environmentObject(themeManager)
                .environmentObject(statusManager)
                .environmentObject(iconManager)
                .environmentObject(userSettings)
                .environmentObject(navigationState)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    themeManager.applyTheme()
                    themeManager.applyTheme()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        checkAndPromptForReview()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                }
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("IDeaful: Error requesting notification permissions: \(error)")
            }
        }
    }
    
    private func incrementLaunchCount() {
        launchCount += 1
    }
    
    private func checkAndPromptForReview() {
        if launchCount == 2 || launchCount == 5 {
            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.foregroundActiveScene else { return }
                SKStoreReviewController.requestReview(in: scene)
                reviewPromptLastShown = launchCount
            }
        }
    }

    private func handleDeepLink(url: URL) {
        guard url.scheme == "oddomens.ideaful", url.host == "dashboard" else { return }
        navigationState.currentView = .main
    }
}


struct ContentView: View {
    @EnvironmentObject var navigationState: NavigationState
    var body: some View {
        ZStack {
            switch navigationState.currentView {
            case .main:
                DashboardView() // Replace this with your main view
            case .achievements:
                AchievementsView() // Replace this with your achievements view
            }
        }
    }
}


