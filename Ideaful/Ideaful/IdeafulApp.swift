import SwiftUI
import StoreKit

@main
struct Ideaful: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("launchCount") private var launchCount = 0
    @AppStorage("reviewPromptLastShown") private var reviewPromptLastShown = 0
    @AppStorage("userChoseToReviewLater") private var userChoseToReviewLater = false
    @AppStorage("userDeclinedToReview") private var userDeclinedToReview = false
    @AppStorage("supportPromptLastShown") private var supportPromptLastShown = 0
    @AppStorage("userDeclinedSupport") private var userDeclinedSupport = false
    
    @State private var showingSupportPopup = false
    
    let persistenceController = PersistenceController.shared

    @StateObject var languageManager = LanguageManager.shared
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(languageManager)
                .environmentObject(themeManager)
                .onAppear {
                    themeManager.applyTheme()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        checkAndPromptForReview()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        checkAndPromptForSupport()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                }
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
                .alert("Support IDeaful Development", isPresented: $showingSupportPopup) {
                    Button("Yes, Please") {
                        supportPromptLastShown = launchCount
                        if let url = URL(string: "https://ko-fi.com/kadynmade") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Button("Not Right Now") {
                        supportPromptLastShown = launchCount
                    }
                    
                    Button("Never ask me again") {
                        userDeclinedSupport = true
                        supportPromptLastShown = launchCount
                    }
                } message: {
                    Text("Hi! 👋 If you're enjoying IDeaful, would you consider supporting its development? Your support helps keep the app updated and ad-free!")
                }
        }
    }

    private func requestNotificationPermission() {
        // ... existing code ...
    }

    private func incrementLaunchCount() {
        launchCount += 1
    }
    
    private func checkAndPromptForReview() {
        if launchCount == 2 || launchCount == 5 {
            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.foregroundActiveScene else { return }
                
                if #available(iOS 18.0, *) {
                    AppStore.requestReview(in: scene)
                } else {
                    SKStoreReviewController.requestReview(in: scene)
                }
                
                reviewPromptLastShown = launchCount
            }
        }
    }

    private func checkAndPromptForSupport() {
        guard !userDeclinedSupport else { return }
        
        if launchCount >= 10 && (launchCount - supportPromptLastShown) >= 10 {
            showingSupportPopup = true
        }
    }

    private func handleDeepLink(url: URL) {
        guard url.scheme == "oddomens.ideaful", url.host == "dashboard" else { return }
        // ... existing code ...
    }

}